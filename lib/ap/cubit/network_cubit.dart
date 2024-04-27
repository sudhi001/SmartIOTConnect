import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_tools/network_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartiotconnect/api/network_api.dart';
import 'package:smartiotconnect/app_logger.dart';

sealed class NetworkConfigState extends Equatable {
  const NetworkConfigState({
    this.password = '',
    this.ssid = '',
    this.deviceIP = '',
  });
  final String password;
  final String ssid;
  final String deviceIP;

  @override
  List<Object> get props => [password, ssid, deviceIP];
}

class SubmitFormEvent extends NetworkConfigState {
  const SubmitFormEvent({
    required super.password,
    required super.ssid,
    required super.deviceIP,
  });
}

final class NetworkConfigStateInitial extends NetworkConfigState {}

final class NetworkConfigStateLoading extends NetworkConfigState {}

class NetworkConfigFormCubit extends Cubit<NetworkConfigState> {
  NetworkConfigFormCubit() : super(NetworkConfigStateInitial()) {
    int();
  }

  Future<void> int() async {
    emit(NetworkConfigStateLoading());
    final prefs = await SharedPreferences.getInstance();
    final password = prefs.getString('password');
    final ssid = prefs.getString('ssid');
    final deviceIP = prefs.getString('deviceIP');
    emit(
      SubmitFormEvent(
        password: password ?? '',
        ssid: ssid ?? '',
        deviceIP: deviceIP ?? '',
      ),
    );
  }

  Future<void> submitFormWithSave({
    required String password,
    required String ssid,
    required String deviceIP,
  }) async {
    emit(NetworkConfigStateLoading());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
    await prefs.setString('ssid', ssid);
    await prefs.setString('deviceIP', deviceIP);
    emit(
      SubmitFormEvent(
        password: password,
        ssid: ssid,
        deviceIP: deviceIP,
      ),
    );
  }

  Future<void> submitForm({
    required String password,
    required String ssid,
    required String deviceIP,
  }) async {
    emit(NetworkConfigStateLoading());
    emit(
      SubmitFormEvent(
        password: password,
        ssid: ssid,
        deviceIP: deviceIP,
      ),
    );
  }

  void postNetworkConfig(NetworkConfigState state, Function onCallBack) {
    emit(NetworkConfigStateLoading());
    NetworkAPI.postNetworkConfig(
      password: state.password,
      ssid: state.ssid,
      baseUrl: 'http://${state.deviceIP}',
    ).then((value) {
      emit(
        SubmitFormEvent(
          password: state.password,
          ssid: state.ssid,
          deviceIP: state.deviceIP,
        ),
      );
      onCallBack.call();
    }).catchError((error) {
      emit(
        SubmitFormEvent(
          password: state.password,
          ssid: state.ssid,
          deviceIP: state.deviceIP,
        ),
      );
      onCallBack.call();
    });
  }
}

class NetworkState extends Equatable {
  const NetworkState({required this.ipAddresses});

  final List<ActiveHost> ipAddresses;

  @override
  List<Object?> get props => [ipAddresses];
}

class NetworkStateInitial extends NetworkState {
  const NetworkStateInitial({super.ipAddresses = const []});
}

class NetworkStateLoading extends NetworkState {
  const NetworkStateLoading({super.ipAddresses = const []});
}

class NetworkCubit extends Cubit<NetworkState> {
  NetworkCubit() : super(const NetworkStateInitial()) {
    scanNetwork();
  }

  Future<void> scanNetwork() async {
    try {
      emit(const NetworkStateLoading());
      final interface = await NetInterface.localInterface();
      final hosts = <ActiveHost>[];
      await for (final host
          in HostScannerService.instance.scanDevicesForSinglePort(
        interface!.ipAddress.substring(0, interface.ipAddress.lastIndexOf('.')),
        80,
      )) {
        hosts.add(host);
      }
      emit(NetworkState(ipAddresses: hosts));
    } catch (e) {
      emit(const NetworkState(ipAddresses: []));
      logger.e('Failed to scan network: $e');
    }
  }
}
