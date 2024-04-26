import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smartiotconnect/api/network_api.dart';

sealed class IotStarterConnectionState extends Equatable {
  const IotStarterConnectionState({this.data = const {}});
  final Map<String, dynamic> data;
  @override
  List<Object> get props => [data];
}

final class IotStarterConnectionLoading extends IotStarterConnectionState {
  const IotStarterConnectionLoading();
}

final class IotStarterConnectionInitial extends IotStarterConnectionState {
  const IotStarterConnectionInitial();
}

final class IotStarterConnectionCompleted extends IotStarterConnectionState {
  const IotStarterConnectionCompleted({super.data});
}

class IotStarterConnectionCubit extends Cubit<IotStarterConnectionState> {
  IotStarterConnectionCubit() : super(const IotStarterConnectionInitial());

  void loading() {
    emit(const IotStarterConnectionLoading());
  }

  void init(BuildContext context) {
    emit(const IotStarterConnectionLoading());
    NetworkAPI.getReport('http://192.168.1.46').then((value) {
      emit(IotStarterConnectionCompleted(data: value));
    }).catchError((value) {
      emit(const IotStarterConnectionCompleted());
    });
  }
}
