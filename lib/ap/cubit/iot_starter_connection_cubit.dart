import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:network_tools/network_tools.dart';
import 'package:smartiotconnect/api/network_api.dart';

sealed class IotStarterConnectionState extends Equatable {
  const IotStarterConnectionState({this.data = const {}, this.activeHost});
  final Map<String, dynamic> data;
  final ActiveHost? activeHost;
  @override
  List<Object> get props => [data, activeHost?.address ?? ''];
}

final class IotStarterConnectionLoading extends IotStarterConnectionState {
  const IotStarterConnectionLoading({super.activeHost});
}

final class IotStarterConnectionInitial extends IotStarterConnectionState {
  const IotStarterConnectionInitial();
}

final class IotStarterConnectionCompleted extends IotStarterConnectionState {
  const IotStarterConnectionCompleted({super.data, super.activeHost});
}

class IotStarterConnectionCubit extends Cubit<IotStarterConnectionState> {
  IotStarterConnectionCubit() : super(const IotStarterConnectionInitial());

  void loading() {
    emit(const IotStarterConnectionLoading());
  }

  void init(BuildContext context, ActiveHost activeHost) {
    emit(IotStarterConnectionLoading(
      activeHost: activeHost,
    ),);
    NetworkAPI.getReport('http://${activeHost.address}').then((value) {
      emit(IotStarterConnectionCompleted(data: value, activeHost: activeHost));
    }).catchError((value) {
      emit(IotStarterConnectionCompleted(
        activeHost: activeHost,
      ),);
    });
  }
}
