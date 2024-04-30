import 'dart:async';

import 'package:smartiotconnect/ble/ble_controller.dart';

class BluetoothController extends BluetoothConnector {
  BluetoothController() : super();
  String _textfieldValue = '{"action":"BONJOUR"}';

  final _textStream = StreamController<String>();

  @override
  Future<void> sendInit() async {
    await send(_textfieldValue);
    await subscribeServiceString(RECIVE.string, _textStream);
  }

  @override
  Future<void> close() async {
    await _textStream.close();
  }

  Future<void> send(String text) async {
    _textfieldValue = text;
    await writeServiceString(
      characteristicGuid: SEND.string,
      msg: text,
      importand: true,
    );
  }

  Stream<String>? getStringStream() {
    return _textStream.stream;
  }

  @override
  StreamController<String>? getStringStreamController() {
    return _textStream;
  }
}
