import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class DeviceStorageState extends Equatable {
  const DeviceStorageState({
    this.password = '',
    this.ssid = '',
  });
  final String password;
  final String ssid;

  @override
  List<Object> get props => [password, ssid];
}

class DeviceStorageStateWithData extends DeviceStorageState {
  const DeviceStorageStateWithData({
    required super.password,
    required super.ssid,
  });
}

final class DeviceStorageStateInitial extends DeviceStorageState {}

final class DeviceStorageStateLoading extends DeviceStorageState {}

class DeviceStorageCubit extends Cubit<DeviceStorageState> {
  DeviceStorageCubit() : super(DeviceStorageStateInitial()) {
    int();
  }

  Future<void> int() async {
    emit(DeviceStorageStateLoading());
    final prefs = await SharedPreferences.getInstance();
    final password = prefs.getString('password');
    final ssid = prefs.getString('ssid');
    emit(
      DeviceStorageStateWithData(
        password: password ?? '',
        ssid: ssid ?? '',
      ),
    );
  }

  Future<void> submitFormWithSave({
    required String password,
    required String ssid,
  }) async {
    emit(DeviceStorageStateLoading());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
    await prefs.setString('ssid', ssid);
    emit(
      DeviceStorageStateWithData(
        password: password,
        ssid: ssid,
      ),
    );
  }

  Future<void> submitForm({
    required String password,
    required String ssid,
  }) async {
    emit(DeviceStorageStateLoading());
    emit(
      DeviceStorageStateWithData(
        password: password,
        ssid: ssid,
      ),
    );
  }
}

class DeviceConnectionCubit extends Cubit<bool> {
  DeviceConnectionCubit() : super(false);

  void connected() {
    emit(true);
  }

  void disConnected() {
    emit(false);
  }
}
