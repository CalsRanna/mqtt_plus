import 'package:mqtt_plus/mqtt_plus.dart';

void main() async {
  final client = MqttClient(url: 'mqtt://localhost:1883');
  await client.connect();
  await client.subscribe('/foo/bar');
}
