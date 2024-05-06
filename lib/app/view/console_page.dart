
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartiotconnect/app/cubit/device_storage_cubit.dart';
import 'package:smartiotconnect/app/view/common_ui.dart';
import 'package:smartiotconnect/di.dart';
import 'package:smartiotconnect/soundpool.dart';

class ConsolePage extends StatelessWidget {
  const ConsolePage({super.key});



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceConnectionCubit, bool>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title:  Text('HOME',  style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.greenAccent),),

          ),
          bottomNavigationBar: SafeArea(
            child: TextButton.icon(
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
                await SoundProvider.of(context).click!.play();
                // ignore: use_build_context_synchronously
                await bleCtr.startScan(context);
              }
                  : () {
                bleCtr.disconnect(context);
              },
              icon: Icon(
                !state ? Icons.bluetooth_searching : Icons.bluetooth_connected,
                color: Colors.greenAccent,
                size: 32,
              ),
              label: Text(
                !state ? 'CONNECT DEVICE' : 'DISCONNECT DEVICE',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.greenAccent),
              ),
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
                    final data = snapshot.data ?? '{}';
                    Map<String, dynamic> dataMap;
                    try {
                      dataMap = jsonDecode(data) as Map<String, dynamic>;
                      // Process dataMap
                    } catch (e) {
                      dataMap = {};
                    }

                    return dataMap.isEmpty? Text(
                      data,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.greenAccent),
                    ): dataMap['action'] == 'DATA'
                        ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: buildDataWidgets(dataMap, context),
                        ),
                      ),
                    )
                        : dataMap['action'] == 'LOG'
                        ? Text(
                      '${dataMap['log'] ?? ''}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.greenAccent),
                    )
                        : Text(
                      data,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Colors.greenAccent),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
