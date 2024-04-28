import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartiotconnect/ap/cubit/iot_starter_connection_cubit.dart';
import 'package:smartiotconnect/ap/cubit/network_cubit.dart';
import 'package:smartiotconnect/api/network_api.dart';
import 'package:smartiotconnect/utils/dialof_utils.dart';

class NetworkConfigForm extends StatelessWidget {
  NetworkConfigForm({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IotStarterConnectionCubit, IotStarterConnectionState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Network Configuration'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  tooltip: 'RESET DEVICE',
                  onPressed: () {
                    BottomSheetUtils.showBottomSheet(
                      context,
                      title: 'Are you sure?',
                      message: 'Do you want to reset the device.',
                      positiveText: 'Reset Device Now',
                      onPositivePressed: () {
                        final host = context
                            .read<IotStarterConnectionCubit>()
                            .state
                            .address;
                        if (host != null) {
                          NetworkAPI.resetDevice(
                            baseUrl: host,
                          ).then((value) {
                            Navigator.pop(context);
                          }).onError((error, stackTrace) {
                            Navigator.pop(context);
                          });
                        }
                      },
                      negativeText: 'Cancel',
                      onNegativePressed: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<NetworkConfigFormCubit, NetworkConfigState>(
              builder: (context, networkstate) {
                if (networkstate is NetworkConfigStateLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue:
                            context.read<NetworkConfigFormCubit>().state.ssid,
                        decoration: const InputDecoration(
                          labelText: 'SSID',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter SSID';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          context.read<NetworkConfigFormCubit>().submitForm(
                                deviceIP: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .deviceIP,
                                password: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .password,
                                ssid: newValue ?? '',
                              );
                        },
                        onChanged: (value) {
                          context.read<NetworkConfigFormCubit>().submitForm(
                                deviceIP: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .deviceIP,
                                password: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .password,
                                ssid: value,
                              );
                        },
                      ),
                      TextFormField(
                        initialValue: context
                            .read<NetworkConfigFormCubit>()
                            .state
                            .password,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          context.read<NetworkConfigFormCubit>().submitForm(
                                deviceIP: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .deviceIP,
                                password: newValue ?? '',
                                ssid: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .ssid,
                              );
                        },
                        onChanged: (value) {
                          context.read<NetworkConfigFormCubit>().submitForm(
                                deviceIP: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .deviceIP,
                                password: value,
                                ssid: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .ssid,
                              );
                        },
                      ),
                      TextFormField(
                        initialValue: context
                            .read<NetworkConfigFormCubit>()
                            .state
                            .deviceIP,
                        decoration: const InputDecoration(
                          labelText: 'Device IP',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Device IP';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          context.read<NetworkConfigFormCubit>().submitForm(
                                deviceIP: newValue ?? '',
                                password: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .password,
                                ssid: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .ssid,
                              );
                        },
                        onChanged: (value) {
                          context.read<NetworkConfigFormCubit>().submitForm(
                                deviceIP: value,
                                password: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .password,
                                ssid: context
                                    .read<NetworkConfigFormCubit>()
                                    .state
                                    .ssid,
                              );
                        },
                      ),
                      if (networkstate is NetworkConfigStateLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      _formKey.currentState?.save();
                                      context
                                          .read<NetworkConfigFormCubit>()
                                          .submitFormWithSave(
                                            deviceIP: context
                                                .read<NetworkConfigFormCubit>()
                                                .state
                                                .deviceIP
                                                .trim(),
                                            password: context
                                                .read<NetworkConfigFormCubit>()
                                                .state
                                                .password
                                                .trim(),
                                            ssid: context
                                                .read<NetworkConfigFormCubit>()
                                                .state
                                                .ssid
                                                .trim(),
                                          );
                                      context
                                          .read<NetworkConfigFormCubit>()
                                          .postNetworkConfig(
                                              state.address, networkstate, () {
                                        Navigator.pop(context);
                                      });
                                    }
                                  },
                                  child: const Text('Submit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
