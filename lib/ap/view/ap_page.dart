import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartiotconnect/ap/cubit/device_storage_cubit.dart';
import 'package:smartiotconnect/ap/view/network_config_page.dart';
import 'package:smartiotconnect/ble/ble.dart';
import 'package:smartiotconnect/soundpool.dart';
import 'package:smartiotconnect/utils/dialof_utils.dart';

class APPage extends StatelessWidget {
  APPage({super.key});

  final bleCtr = BluetoothController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceConnectionCubit, bool>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SMART IOT Connect'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: () {
                    if (state) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<NetworkConfigForm>(
                          builder: (context) => NetworkConfigForm(bleCtr),
                        ),
                      );
                    } else {
                      BottomSheetUtils.showMessage(
                        context,
                        message: 'Please connect the device first.',
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: TextButton.icon(
              onPressed: !state
                  ? () async {
                      var status = await Permission.bluetooth.status;
                      if (status.isDenied) {
                        await Permission.bluetooth.request();
                      }
                      status = await Permission.bluetoothConnect.status;
                      if (status.isDenied) {
                        await Permission.bluetoothConnect.request();
                      }
                      status = await Permission.bluetoothScan.status;
                      if (status.isDenied) {
                        await Permission.bluetoothScan.request();
                      }
                      // ignore: use_build_context_synchronously
                      await SoundProvider.of(context).click!.play();
                      // ignore: use_build_context_synchronously
                      await bleCtr.startScan(context);
                    }
                  : () {
                      bleCtr.disconnect(context);
                    },
              icon: Icon(
                !state ? Icons.bluetooth_searching : Icons.bluetooth_connected,
                color: Colors.greenAccent,
                size: 32,
              ),
              label: Text(
                !state ? 'CONNECT DEVICE' : 'DISCONNECT DEVICE',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.greenAccent),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<String>(
                  initialData:
                      'Please click on the Connect Device Button to Scan the BLE Device.',
                  stream: bleCtr.getStringStream(),
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? '{}';
                    final dataMap = jsonDecode(data) as Map<String, dynamic>;

                    return dataMap['action'] == 'DATA'
                        ? Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildDataWidgets(dataMap, context),
                              ),
                            ),
                          )
                        : dataMap['action'] == 'LOG'
                            ? Text(
                                '${dataMap['log'] ?? ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.greenAccent),
                              )
                            : Text(
                                data,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.greenAccent),
                              );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDataWidgets(
      Map<String, dynamic> dataMap, BuildContext context) {
    return [
      _buildDataWidget(dataMap, 'Device WiFi Local IP',
          dataMap['deviceWifiLocalIP'], context),
      _buildDataWidget(
          dataMap, 'Soil Moisture', dataMap['soilMoisture'], context),
      _buildDataWidget(
          dataMap, 'Soil Temperature', dataMap['soilTemperature'], context),
      _buildDataWidget(dataMap, 'Soil EC', dataMap['soilEC'], context),
      _buildDataWidget(dataMap, 'Soil PH', dataMap['soilPH'], context),
      _buildDataWidget(
          dataMap, 'Soil Nitrogen', dataMap['soilNitrogen'], context),
      _buildDataWidget(
          dataMap, 'Soil Phosphorous', dataMap['soilPhosphorous'], context),
      _buildDataWidget(
          dataMap, 'Soil Potassium', dataMap['soilPotassium'], context),
      _buildDataWidget(dataMap, 'Atmospheric Temperature',
          dataMap['atmosphericTemperature'], context),
      _buildDataWidget(dataMap, 'Atmospheric Humidity',
          dataMap['atmosphericHumidity'], context),
      _buildDataWidget(dataMap, 'Spray Module Status',
          dataMap['sprayModuleStatus'], context),
      _buildDataWidget(dataMap, 'Water Module Status',
          dataMap['waterModuleStatus'], context),
      _buildDataWidget(
          dataMap, 'Will Spray On', dataMap['willSprayOn'], context),
      _buildDataWidget(dataMap, 'Will Water Module On',
          dataMap['willWaterModuleOn'], context),
      _buildDataWidget(
          dataMap, 'Is WiFi Connected', dataMap['isWIFIConnectd'], context),
    ];
  }

  Widget _buildDataWidget(Map<String, dynamic> dataMap, String title,
      dynamic value, BuildContext context) {
    return Text(
      '$title: $value',
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: Colors.greenAccent),
    );
  }
}
