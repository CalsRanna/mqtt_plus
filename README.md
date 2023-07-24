# Mqtt plus

![Current Version](https://img.shields.io/badge/0.0.4-blue?style=flat-square&label=version)

Build a convenient mqtt client, provide emitter and handler to write business code here.

## Install

```bash
flutter pub add mqtt_plus
```

## Getting started

```dart
import 'package:mqtt_plus/mqtt_plus.dart';

void main() async {
  final client = MqttClient(url: 'mqtt://localhost:1883');
  await client.connect();
  await client.subscribe('/foo/bar');
}

```
