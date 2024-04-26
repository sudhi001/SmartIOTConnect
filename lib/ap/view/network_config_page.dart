import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartiotconnect/ap/cubit/network_cubit.dart';
import 'package:smartiotconnect/api/network_api.dart';
import 'package:smartiotconnect/utils/dialof_utils.dart';

class NetworkConfigForm extends StatelessWidget {
  NetworkConfigForm({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                    NetworkAPI.resetDevice(
                      baseUrl: 'http://192.168.1.46',
                    ).then((value) {
                      Navigator.pop(context);
                    }).onError((error, stackTrace) {
                      Navigator.pop(context);
                    });
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
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue:
                        context.read<NetworkConfigFormCubit>().state.deviceId,
                    decoration: const InputDecoration(
                      labelText: 'Device ID',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter device ID';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      context.read<NetworkConfigFormCubit>().submitForm(
                            context
                                .read<NetworkConfigFormCubit>()
                                .state
                                .password,
                            newValue ?? '',
                            context.read<NetworkConfigFormCubit>().state.ssid,
                          );
                    },
                    onChanged: (value) {
                      context.read<NetworkConfigFormCubit>().submitForm(
                            context
                                .read<NetworkConfigFormCubit>()
                                .state
                                .password,
                            value,
                            context.read<NetworkConfigFormCubit>().state.ssid,
                          );
                    },
                  ),
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
                            context
                                .read<NetworkConfigFormCubit>()
                                .state
                                .password,
                            context
                                .read<NetworkConfigFormCubit>()
                                .state
                                .deviceId,
                            newValue ?? '',
                          );
                    },
                    onChanged: (value) {
                      context.read<NetworkConfigFormCubit>().submitForm(
                            context
                                .read<NetworkConfigFormCubit>()
                                .state
                                .password,
                            context
                                .read<NetworkConfigFormCubit>()
                                .state
                                .deviceId,
                            value,
                          );
                    },
                  ),
                  TextFormField(
                    initialValue:
                        context.read<NetworkConfigFormCubit>().state.password,
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
                            newValue ?? '',
                            context
                                .read<NetworkConfigFormCubit>()
                                .state
                                .deviceId,
                            context.read<NetworkConfigFormCubit>().state.ssid,
                          );
                    },
                    onChanged: (value) {
                      context.read<NetworkConfigFormCubit>().submitForm(
                            value,
                            context
                                .read<NetworkConfigFormCubit>()
                                .state
                                .deviceId,
                            context.read<NetworkConfigFormCubit>().state.ssid,
                          );
                    },
                  ),
                  if (state is NetworkConfigStateLoading)
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
                                  final password = context
                                      .read<NetworkConfigFormCubit>()
                                      .state
                                      .password;
                                  final deviceId = context
                                      .read<NetworkConfigFormCubit>()
                                      .state
                                      .deviceId;
                                  final ssid = context
                                      .read<NetworkConfigFormCubit>()
                                      .state
                                      .ssid;
                                  context
                                      .read<NetworkConfigFormCubit>()
                                      .submitForm(password, deviceId, ssid);
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
  }
}
