import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartiotconnect/ap/cubit/device_storage_cubit.dart';
import 'package:smartiotconnect/ble/ble.dart';
import 'package:smartiotconnect/utils/dialof_utils.dart';

class NetworkConfigForm extends StatelessWidget {
  NetworkConfigForm(this.bluetoothController, {super.key});
  final BluetoothController bluetoothController;
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
                    bluetoothController.send('{"action":"RESET"}');
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
        child: BlocBuilder<DeviceStorageCubit, DeviceStorageState>(
          builder: (context, networkstate) {
            if (networkstate is DeviceStorageStateLoading) {
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
                    initialValue: context.read<DeviceStorageCubit>().state.ssid,
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
                      context.read<DeviceStorageCubit>().submitForm(
                            password: context
                                .read<DeviceStorageCubit>()
                                .state
                                .password,
                            ssid: newValue ?? '',
                          );
                    },
                    onChanged: (value) {
                      context.read<DeviceStorageCubit>().submitForm(
                            password: context
                                .read<DeviceStorageCubit>()
                                .state
                                .password,
                            ssid: value,
                          );
                    },
                  ),
                  TextFormField(
                    initialValue:
                        context.read<DeviceStorageCubit>().state.password,
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
                      context.read<DeviceStorageCubit>().submitForm(
                            password: newValue ?? '',
                            ssid: context.read<DeviceStorageCubit>().state.ssid,
                          );
                    },
                    onChanged: (value) {
                      context.read<DeviceStorageCubit>().submitForm(
                            password: value,
                            ssid: context.read<DeviceStorageCubit>().state.ssid,
                          );
                    },
                  ),
                  if (networkstate is DeviceStorageStateLoading)
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
                                      .read<DeviceStorageCubit>()
                                      .state
                                      .password
                                      .trim();
                                  final ssid = context
                                      .read<DeviceStorageCubit>()
                                      .state
                                      .ssid
                                      .trim();
                                  context
                                      .read<DeviceStorageCubit>()
                                      .submitFormWithSave(
                                        password: password,
                                        ssid: ssid,
                                      );
                                  bluetoothController.send(
                                    ' {"action":"CONFIGURE","ssid":"$ssid","password":"$password"}',
                                  );
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
