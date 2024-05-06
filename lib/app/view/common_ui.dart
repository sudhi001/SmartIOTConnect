
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


List<Widget> buildDataWidgets(
    Map<String, dynamic> dataMap,
    BuildContext context,
    {bool withTime=false,}
    ) {
  return [
    if(withTime) _buildDataWidget(
      dataMap,
      'Time',
      formattedTime(dataMap['timestamp'] )
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

String formattedTime(Timestamp dateString) {
 final dateTime = DateTime.fromMillisecondsSinceEpoch(dateString.millisecondsSinceEpoch);
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
