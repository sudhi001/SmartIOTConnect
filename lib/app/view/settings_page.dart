import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartiotconnect/app/cubit/device_storage_cubit.dart';
import 'package:smartiotconnect/app/view/set_property_form.dart';
import 'package:smartiotconnect/di.dart';
import 'package:smartiotconnect/utils/dialof_utils.dart';

class SettingsConfigForm extends StatelessWidget {
  SettingsConfigForm( {super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
                    bleCtr.send('{"action":"RESET"}');
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text('Change wifi configuration',   style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.greenAccent),),
              Padding(
                padding: const EdgeInsets.all(8),
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
                            style: const TextStyle(color: Colors.white),
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
                            style: const TextStyle(color: Colors.white),
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
                                          bleCtr.send(
                                            '{"action":"CONFIGURE","ssid":"$ssid","password":"$password"}',
                                          );
                                        }
                                      },
                                      child: const Text('CHANGE WIFI SETTINGS'),
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
              Text('Change Properties',   style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.greenAccent),),
              const SetPropertyWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
