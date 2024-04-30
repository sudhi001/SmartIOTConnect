import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smartiotconnect/ap/cubit/device_storage_cubit.dart';
import 'package:smartiotconnect/app_logger.dart';
import 'package:smartiotconnect/soundpool.dart';

class RECIVE {
  static const service = 'f2f9a4de-ef95-4fe1-9c2e-ab5ef6f0d6e9';
  static const string = '9e8fafe1-8966-4276-a3a3-d0b00269541e';
}

class SEND {
  static const service = '1450dbb0-e48c-4495-ae90-5ff53327ede4';
  static const string = '9393c756-78ea-4629-a53e-52fb10f9a63f';
}

class ConfigNameController {
  ConfigNameController(String deviceName) {
    _controller = BehaviorSubject.seeded(deviceName);
  }
  late BehaviorSubject<String> _controller;

  ValueStream<String> get stream => _controller.stream;
  String? get current => _controller.value;

  void setDeviceName(String name) => _controller.add(name);
}

class BluetoothConnector {
  BluetoothConnector() {
    initDevice();
  }
  ConfigNameController settings = ConfigNameController('SMART_IOT');
  BluetoothDevice? device;
  final BehaviorSubject<int> _controller = BehaviorSubject.seeded(0);
  bool isBtAvalible = false;
  bool isScanning = false;
  bool isConnected = false;
  bool isWriting = false;
  List<MapEntry<String, List<int>>> msgStack = [];
  Map<String, BluetoothCharacteristic> map = {};
  Future<void> sendInit() async {}
  Future<void> close() async {}
  ValueStream<int> get stream => _controller.stream;
  List<BluetoothDevice> _systemDevices = [];
  int? get current => _controller.value;
  DeviceConnectionCubit? _connectionCubit;
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  SoundEffects? soundEffects;
  Future<void> startScan(BuildContext context) async {
    soundEffects = SoundProvider.of(context);
    _connectionCubit = context.read<DeviceConnectionCubit>();
    if (!isScanning) {
      _systemDevices = FlutterBluePlus.connectedDevices.isEmpty
          ? await FlutterBluePlus.systemDevices
          : FlutterBluePlus.connectedDevices;

      _systemDevices.addAll(await FlutterBluePlus.bondedDevices);
      for (final connected in _systemDevices) {
        logger.i('Connected: ${connected.platformName}');
        final value = await setDevice(connected);
        if (value) {
          await soundEffects?.information!.play();
          _connectionCubit?.connected();
        }
      }
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 16));
    }
  }

  Future<void> stopScan() async {
    if (isScanning) {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> setLog(String msg) async {
    await soundEffects?.typingLong!.play();
    getStringStreamController()?.sink.add('{"action":"LOG","log":"$msg"}');
  }

  Future<void> disconnect(BuildContext context) async {
    _connectionCubit = context.read<DeviceConnectionCubit>();
    await device?.disconnect();
    if (device?.isDisconnected ?? false) {
      await setLog('Disconnected');
      _connectionCubit?.disConnected();

      map.clear();
      device = null;
      isConnected = false;
      isScanning = false;
    }
  }

  Future<void> initDevice() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    FlutterBluePlus.adapterState.listen((data) {
      adapterState = data;
      logger.i('adapterState $adapterState');
    });

    FlutterBluePlus.isScanning.listen((data) {
      isScanning = data;
      logger.i(isScanning);
      if (isScanning) {
        setLog('Device scanning....');
      } else {
        setLog('Device scanning completed.');
      }
    });

    FlutterBluePlus.scanResults.listen((scans) {
      for (final scan in scans) {
        logger.i('scan ${scan.device.remoteId}: ${scan.device.platformName}');
        setScanResult(scan);
      }
    });
  }

  Future<void> setScanResult(ScanResult scan) async {
    final device = scan.device;
    await setDevice(device);
  }

  Future<bool> setDevice(BluetoothDevice bledevice) async {
    if (bledevice.platformName.isNotEmpty) {
      await setLog('Found Device ${bledevice.platformName}');
    }
    if (bledevice.platformName == 'SMART_IOT') {
      await setLog('Connected: ${bledevice.platformName}');
      await stopScan();
      logger.i(bledevice.platformName);

      map = HashMap<String, BluetoothCharacteristic>();
      device = bledevice;
      isConnected = true;
      if (Platform.isAndroid) {
        await device!.connect();
      } else {
        await device!.connect(autoConnect: true, mtu: null);
      }
      device?.connectionState.listen((event) {
        if (device?.isDisconnected ?? false) {
          disconnectd();
        }
      });
      final subscription = device!.mtu.listen((int mtu) {
        logger.i('mtu $mtu');
      });
      device!.cancelWhenDisconnected(subscription);

      final services = await device!.discoverServices();
      for (final service in services) {
        for (final c in service.characteristics) {
          if (c.properties.read) {
            map[c.uuid.toString()] = c;
            final read = c.properties.read;
            final write = c.properties.write;
            final notify = c.properties.notify;
            final indicate = c.properties.indicate;
            var properties = '';
            properties += (read ? 'R' : '') + (write ? 'W' : '');
            properties += (notify ? 'N' : '') + (indicate ? 'I' : '');
            logger.i('${c.serviceUuid} ${c.uuid} [$properties] found!');

            if (notify || indicate) {
              await c.setNotifyValue(true);
            }
          }
        }
      }
      await sendInit();
      return true;
    } else {
      if (bledevice.isConnected) {
        await setLog('Device ${bledevice.platformName} is already connectd.');
        await bledevice.disconnect();
        await setLog('Device ${bledevice.platformName} is disconnected.');
      }
      return false;
    }
  }

  StreamController<String>? getStringStreamController() {
    return null;
  }

  Future<void> subscribeService<T>(
    String characteristicGuid,
    StreamController<T> controller,
    T Function(List<int>) parse,
  ) async {
    final characteristic = map[characteristicGuid];
    characteristic?.onValueReceived.listen((onData) async {
      if (!controller.isClosed) {
        connectd();
        final value = parse(onData);
        controller.sink.add(value);
      }
    });
    await characteristic!.setNotifyValue(true);
  }

  Future<void> subscribeServiceString(
    String guid,
    StreamController<String> controller,
  ) async {
    String parse(List<int> data) => String.fromCharCodes(data);
    await subscribeService<String>(guid, controller, parse);
  }

  Future<List<int>> readService(String characteristicGuid) async {
    final characteristic = map[characteristicGuid]!;
    logger.i(map);
    return characteristic.read();
  }

  Future<void> writeServiceString({
    required String characteristicGuid,
    required String msg,
    required bool importand,
  }) async {
    await writeService(
      characteristicGuid: characteristicGuid,
      data: utf8.encode(msg),
      importand: importand,
    );
  }

  Future<void> writeService({
    required String characteristicGuid,
    required List<int> data,
    required bool importand,
  }) async {
    // print("$characteristicGuid $isWriting");
    if (!isWriting) {
      isWriting = true;
      await writeCharacteristics(characteristicGuid, data);

      if (msgStack.isNotEmpty) {
        for (var i = 0; i < msgStack.length; i++) {
          await writeCharacteristics(msgStack[i].key, msgStack[i].value);
        }
        msgStack = [];
      }
      isWriting = false;
    } else if (importand) {
      msgStack.add(MapEntry(characteristicGuid, data));
    }
  }

  Future<void> writeCharacteristics(
    String characteristicGuid,
    List<int> data,
  ) async {
    final characteristic = map[characteristicGuid];
    if (characteristic != null) {
      await characteristic.write(data);
      return;
    }
  }

  void connectd() {
    _connectionCubit?.connected();
  }

  void disconnectd() {
    soundEffects?.warning!.play();
    setLog('Device disconnectd');
    _connectionCubit?.disConnected();
  }
}
