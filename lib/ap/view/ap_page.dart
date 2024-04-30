import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartiotconnect/ap/cubit/device_storage_cubit.dart';
import 'package:smartiotconnect/ap/view/network_config_page.dart';
import 'package:smartiotconnect/ble/ble.dart';
import 'package:smartiotconnect/utils/dialof_utils.dart';

class APPage extends StatelessWidget {
  APPage({super.key});

  final bleCtr = BluetoothController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceConnectionCubit, bool>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('SMART IOT Connect'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: () {
                    if (state) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<NetworkConfigForm>(
                          builder: (context) => NetworkConfigForm(bleCtr),
                        ),
                      );
                    } else {
                      BottomSheetUtils.showMessage(
                        context,
                        message: 'Please connect the device first.',
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: TextButton(
              onPressed: !state
                  ? () async {
                      var status = await Permission.bluetooth.status;
                      if (status.isDenied) {
                        await Permission.bluetooth.request();
                      }
                      status = await Permission.bluetoothConnect.status;
                      if (status.isDenied) {
                        await Permission.bluetoothConnect.request();
                      }
                      status = await Permission.bluetoothScan.status;
                      if (status.isDenied) {
                        await Permission.bluetoothScan.request();
                      }
                      // ignore: use_build_context_synchronously
                      await bleCtr.startScan(context);
                    }
                  : () {
                      bleCtr.disconnect(context);
                    },
              child: Text(!state ? 'CONNECT DEVICE' : 'DISCONNECT DEVICE'),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<String>(
                  initialData:
                      'Please click on the Connect Device Button to Scan the BLE Device.',
                  stream: bleCtr.getStringStream(),
                  builder: (context, snapshot) {
                    return Text(snapshot.data ?? '');
                  },
                ),
              ),
              // if (state.data.isNotEmpty)
              //   Padding(
              //     padding: const EdgeInsets.all(16),
              //     child: ListView.builder(
              //       shrinkWrap: true,
              //       physics: const NeverScrollableScrollPhysics(),
              //       itemCount: state.data.length,
              //       itemBuilder: (context, index) {
              //         final key = state.data.keys.toList()[index];
              //         final dynamic value = state.data.values.toList()[index];
              //         return Row(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             Expanded(child: Text(key)),
              //             Expanded(child: Text(value.toString())),
              //           ],
              //         );
              //       },
              //     ),
              //   ),
            ],
          ),
        );
      },
    );
  }
}
