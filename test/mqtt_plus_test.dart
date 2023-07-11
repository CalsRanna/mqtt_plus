import 'package:flutter_test/flutter_test.dart';
import 'package:mqtt_plus/mqtt_plus.dart';

void main() {
  test('Mqtt plus identifier', () {
    final client = MqttClient(url: 'mqtt://localhost:1883');
    expect(client.identifier.contains('mqtt_plus'), true);
  });
}
