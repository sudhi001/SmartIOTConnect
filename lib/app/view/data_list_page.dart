import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartiotconnect/app/view/common_ui.dart';

class DataListPage extends StatefulWidget {
  const DataListPage({super.key});

  @override
  _DataListPageState createState() => _DataListPageState();
}

class _DataListPageState extends State<DataListPage> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Initialize start date as one week ago and end date as today
    _startDate = DateTime.now().subtract(const Duration(days: 7));
    _endDate = DateTime.now();
  }

  DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0, 0);
  }

  DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = startOfDay(picked.start);
        _endDate = endOfDay(picked.end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Log',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.greenAccent),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToCSV,
          ),
        ],
      ),
      body: FirestoreListView<Map<String, dynamic>>(
        query: FirebaseFirestore.instance
            .collection('/device_logs')
            .where('timestamp', isGreaterThanOrEqualTo: _startDate)
            .where('timestamp', isLessThanOrEqualTo: _endDate)
            .orderBy('timestamp', descending: true),
        showFetchingIndicator: true,
        itemBuilder: (context, snapshot) {
          final dataMap = snapshot.data();
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildDataWidgets(dataMap, context, withTime: true),
              ),
            ),
          );
        },
        loadingBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              error.toString(),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.greenAccent),
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportToCSV() async {
    unawaited(
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Exporting data...',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.greenAccent),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    Future<bool> _requestPermission() async {
      var storage = true;
// Only check for storage < Android 13
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        var storagePermissionGranted = false;
        var storageStatus = await Permission.manageExternalStorage.request();
        if (storageStatus.isGranted) {
          storagePermissionGranted = true;
        } else if (storageStatus.isDenied) {
          // The user denied permission, show a request dialog
          storagePermissionGranted = false;
          await openAppSettings();
        } else {
          // Handle permission denied
          storagePermissionGranted = false;
        }
        return storagePermissionGranted;
      } else {
        storage = await Permission.storage.status.isGranted;
        if (storage) {
          return true;
        }
      }

      return false;
    }

    final data = await _fetchDataForCSVExport();
    if (data.isNotEmpty) {
      if (await _requestPermission()) {
        final csvData = const ListToCsvConverter().convert(data);
        final now = DateTime.now().toLocal();
        final formattedDate = '''
${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}''';
        final fileName = 'exported_data_$formattedDate.csv';
        final directory = await getApplicationCacheDirectory();
        final downloadsDirectory = Directory(
            '${directory.path}/export'); // Path to the Downloads directory
        await downloadsDirectory.create(recursive: true);
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsString(csvData);

        Navigator.pop(context); // Dismiss the progress dialog
        await Share.shareXFiles([XFile(file.path)], text: 'Sharing CSV file');
      } else {
        Navigator.pop(context);
        // Permission denied, handle accordingly
        // For example, show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied to write to external storage.'),
          ),
        );
      }
    } else {
      Navigator.pop(context); // Dismiss the progress dialog

      // Show a snackbar or toast if there is no data to export
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No data available to export.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<List<List<dynamic>>> _fetchDataForCSVExport() async {
    // Fetch data from Firestore within the selected date range
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('/device_logs')
        .where('timestamp', isGreaterThanOrEqualTo: _startDate)
        .where('timestamp', isLessThanOrEqualTo: _endDate)
        .orderBy('timestamp', descending: true)
        .get();

    final data = <List<dynamic>>[];
    // Adding the header
    final header = [
      'Action',
      'Atmospheric Humidity',
      'Atmospheric Temperature',
      'Device UniqueId',
      'Device WifiLocalIP',
      'Fcm UniqueId',
      'isWIFIConnected',
      'Soil EC',
      'Soil Moisture',
      'Soil Nitrogen',
      'Soil PH',
      'Soil Phosphorous',
      'Soil Potassium',
      'Soil Temperature',
      'Spray Module Activate Value',
      'Spray Module Status',
      'Timestamp',
      'Water Module Activate Value',
      'Water Module Status',
      'Will Spray On',
      'Will Water Module On'
    ];
    data.add(header);
    for (final doc in querySnapshot.docs) {
      final docData = doc.data() as Map<String, dynamic>?; // Explicit casting
      if (docData != null) {
        final action = docData['action'] as String?;
        final atmosphericHumidity = docData['atmosphericHumidity'] as int?;
        final atmosphericTemperature =
            docData['atmosphericTemperature'] as int?;
        final deviceUniqueId = docData['deviceUniqueId'] as String?;
        final deviceWifiLocalIP = docData['deviceWifiLocalIP'] as String?;
        final fcmUniqueId = docData['fcmUniqueId'] as String?;
        final isWIFIConnected = docData['isWIFIConnected'] as bool?;
        final soilEC = docData['soilEC'] as String?;
        final soilMoisture = docData['soilMoisture'] as int?;
        final soilNitrogen = docData['soilNitrogen'] as String?;
        final soilPH = docData['soilPH'] as int?;
        final soilPhosphorous = docData['soilPhosphorous'] as String?;
        final soilPotassium = docData['soilPotassium'] as String?;
        final soilTemperature = docData['soilTemperature'] as int?;
        final sprayModuleActivateValue =
            docData['sprayModuleActivateValue'] as int?;
        final sprayModuleStatus = docData['sprayModuleStatus'] as bool?;
        final timestamp = docData['timestamp'] as Timestamp?;
        final waterModuleActivateValue =
            docData['waterModuleActivateValue'] as int?;
        final waterModuleStatus = docData['waterModuleStatus'] as bool?;
        final willSprayOn = docData['willSprayOn'] as bool?;
        final willWaterModuleOn = docData['willWaterModuleOn'] as bool?;

        final dataList = [
          action,
          atmosphericHumidity,
          atmosphericTemperature,
          deviceUniqueId,
          deviceWifiLocalIP,
          fcmUniqueId,
          isWIFIConnected,
          soilEC,
          soilMoisture,
          soilNitrogen,
          soilPH,
          soilPhosphorous,
          soilPotassium,
          soilTemperature,
          sprayModuleActivateValue,
          sprayModuleStatus,
          timestamp?.toDate(), // Convert Timestamp to DateTime
          waterModuleActivateValue,
          waterModuleStatus,
          willSprayOn,
          willWaterModuleOn,
        ];
        data.add(dataList);
      }
    }
    print(data);
    return data;
  }
}
