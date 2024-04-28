import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smartiotconnect/api/network_api.dart';

sealed class IotStarterConnectionState extends Equatable {
  const IotStarterConnectionState({this.data = const {}, this.address});
  final Map<String, dynamic> data;
  final String? address;
  @override
  List<Object> get props => [data, address ?? ''];
}

final class IotStarterConnectionLoading extends IotStarterConnectionState {
  const IotStarterConnectionLoading({super.address});
}

final class IotStarterConnectionInitial extends IotStarterConnectionState {
  const IotStarterConnectionInitial();
}

final class IotStarterConnectionCompleted extends IotStarterConnectionState {
  const IotStarterConnectionCompleted({super.data, super.address});
}

class IotStarterConnectionCubit extends Cubit<IotStarterConnectionState> {
  IotStarterConnectionCubit() : super(const IotStarterConnectionInitial());

  void loading() {
    emit(const IotStarterConnectionLoading());
  }

  void init(BuildContext context, String address) {
    emit(
      IotStarterConnectionLoading(
        address: address,
      ),
    );
    NetworkAPI.getReport('http://$address').then((value) {
      emit(IotStarterConnectionCompleted(data: value, address: address));
    }).catchError((value) {
      emit(
        IotStarterConnectionCompleted(
          address: address,
        ),
      );
    });
  }

  void reset() {
    emit(const IotStarterConnectionInitial());
  }
}
