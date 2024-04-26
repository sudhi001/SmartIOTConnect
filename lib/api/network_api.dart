import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkAPI {
  static Future<dynamic> resetDevice({
    required String baseUrl,
  }) async {
    final url = '$baseUrl/api/v1/reset';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = <String, dynamic>{};
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post network config: ${response.statusCode}');
    }
  }

  static Future<dynamic> postNetworkConfig({
    required String password,
    required String deviceId,
    required String ssid,
    required String baseUrl,
  }) async {
    final url = '$baseUrl/api/v1/config/network';
    final headers = <String, String>{'Content-Type': 'application/json'};
    final body = <String, dynamic>{
      'password': password,
      'deviceId': deviceId,
      'ssid': ssid,
      'token': 'AIzaSyAo0cIhTCobdtNek9d6bES_pSp4CjrbIPE',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post network config: ${response.statusCode}');
    }
  }

  static Future<dynamic> getSettings(String baseUrl) async {
    final url = '$baseUrl/api/v1/settings';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get settings: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getReport(String baseUrl) async {
    final url = '$baseUrl/api/v1/report';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get report: ${response.statusCode}');
    }
  }
}
