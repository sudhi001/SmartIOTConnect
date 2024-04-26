import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartiotconnect/api/network_api.dart';

sealed class NetworkConfigState extends Equatable {
  const NetworkConfigState({
    this.password = '',
    this.deviceId = '',
    this.ssid = '',
  });
  final String password;
  final String deviceId;
  final String ssid;

  @override
  List<Object> get props => [password, deviceId, ssid];
}

class SubmitFormEvent extends NetworkConfigState {
  const SubmitFormEvent({
    required super.password,
    required super.deviceId,
    required super.ssid,
  });
}

final class NetworkConfigStateInitial extends NetworkConfigState {}

final class NetworkConfigStateLoading extends NetworkConfigState {}

class NetworkConfigFormCubit extends Cubit<NetworkConfigState> {
  NetworkConfigFormCubit() : super(NetworkConfigStateInitial());
  void submitForm(String password, String deviceId, String ssid) {
    emit(NetworkConfigStateLoading());
    NetworkAPI.postNetworkConfig(
      password: password,
      deviceId: deviceId,
      ssid: ssid,
      baseUrl: 'http://192.168.0.1',
    ).then((value) {
      emit(
        SubmitFormEvent(
          password: password,
          deviceId: deviceId,
          ssid: ssid,
        ),
      );
    }).catchError((error) {
      emit(
        SubmitFormEvent(
          password: password,
          deviceId: deviceId,
          ssid: ssid,
        ),
      );
    });
  }
}
