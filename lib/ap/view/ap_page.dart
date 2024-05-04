import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartiotconnect/ap/cubit/device_storage_cubit.dart';
import 'package:smartiotconnect/ap/view/settings_page.dart';
import 'package:smartiotconnect/ble/ble.dart';
import 'package:smartiotconnect/soundpool.dart';
import 'package:smartiotconnect/utils/dialof_utils.dart';


final bleCtr = BluetoothController();


class APPage extends StatefulWidget {
  const APPage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
  }

  class _MyHomePageState extends State<APPage> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  BlocBuilder<DeviceConnectionCubit, bool>(
            builder: (bcontext, bstate) {
              return Scaffold(
                appBar: AppBar(
                  title:  Text('SMART IOT Connect',  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.greenAccent),),

                ),
                body: IndexedStack(
                  index: tabIndex,
                  children: [
                    const ConsolePage(), //
                    const DataListPAge(),// List of tab contents
                    SettingsConfigForm(bleCtr),
                  ],
                ),
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Colors.black,
                    selectedItemColor: Colors.greenAccent,
                    unselectedItemColor: Colors.white,
                    currentIndex: tabIndex,
                    elevation: 0,
                    enableFeedback: true,
                    onTap: (value) {
                      if(value ==2) {
                        if (!bstate) {
                          BottomSheetUtils.showMessage(
                            context,
                            message: 'Please connect the device first.',
                          );
                          return;
                        }
                      }
                      // ignore: use_build_context_synchronously
                       SoundProvider.of(context).click!.play();
                      setState(() {
                        tabIndex = value; // Update the selected tab index
                      });
                    },
                    items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',

                ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.data_array),
                        label: 'Logs',

                      ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Setting',
                  ),// Dynamically create tabs
                ],
              ),);
            },
          ),
    );
  }
}
class DataListPAge extends StatelessWidget {
  const DataListPAge({super.key});

  @override
  Widget build(BuildContext context) {
    return FirestoreListView<Map<String, dynamic>>(
      query: FirebaseFirestore.instance.collection('/device_logs').orderBy("timestamp",descending: true),
      showFetchingIndicator: true,
      itemBuilder: (context, snapshot) {
        final dataMap = snapshot.data();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildDataWidgets(dataMap, context,withTime: true),
            ),
          ),
        );
      },
    loadingBuilder: (context) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    },
      errorBuilder: (context, error, stackTrace) {
        return  Center(child: Text(error.toString(),  style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Colors.greenAccent),));
      },
    );
  }
}

class ConsolePage extends StatelessWidget {
  const ConsolePage({super.key});



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceConnectionCubit, bool>(
      builder: (context, state) {
        return Scaffold(
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

List<Widget> buildDataWidgets(
    Map<String, dynamic> dataMap,
    BuildContext context,
{bool withTime=false}
    ) {
  return [
    if(withTime) _buildDataWidget(
      dataMap,
      'Time',
      formattedTime(dataMap['timestamp'] as String)
      ,
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Device WiFi Local IP',
      dataMap['deviceWifiLocalIP'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Soil Moisture',
      dataMap['soilMoisture'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Soil Temperature',
      dataMap['soilTemperature'],
      context,
    ),
    _buildDataWidget(dataMap, 'Soil EC', dataMap['soilEC'], context),
    _buildDataWidget(dataMap, 'Soil PH', dataMap['soilPH'], context),
    _buildDataWidget(
      dataMap,
      'Soil Nitrogen',
      dataMap['soilNitrogen'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Soil Phosphorous',
      dataMap['soilPhosphorous'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Soil Potassium',
      dataMap['soilPotassium'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Atmospheric Temperature',
      dataMap['atmosphericTemperature'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Atmospheric Humidity',
      dataMap['atmosphericHumidity'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Spray Module Status',
      dataMap['sprayModuleStatus'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Water Module Status',
      dataMap['waterModuleStatus'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Will Spray On',
      dataMap['willSprayOn'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Will Water Module On',
      dataMap['willWaterModuleOn'],
      context,
    ),
    _buildDataWidget(
      dataMap,
      'Is WiFi Connected',
      dataMap['isWIFIConnected'],
      context,
    ),
  ];
}

String formattedTime(String dateString) {
    if(dateString.isEmpty)return '';
    final dateTime = DateTime.parse(dateString);
    return DateFormat.yMd().add_jms().format(dateTime);
}

Widget _buildDataWidget(
    Map<String, dynamic> dataMap,
    String title,
    dynamic value,
    BuildContext context,
    ) {
  return Text(
    '$title: $value',
    style: Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(color: Colors.greenAccent),
  );
}
