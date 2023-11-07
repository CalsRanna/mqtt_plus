import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_plus/src/mqtt_exception.dart';
import 'package:mqtt_plus/src/mqtt_handler.dart';
import 'package:uuid/uuid.dart';

class MqttClient {
  late MqttServerClient _client;
  final Map<String, MqttHandler> _handlers = {};
  late String _identifier;
  String? _topic;
  void Function()? onAutoReconnect;
  void Function()? onConnected;
  void Function()? onDisconnected;
  void Function(String?)? onSubscribed;
  void Function(String?)? onUnsubscribed;

  /// So far, *url* must contains protocol and port, e.g. mqtt://localhost:1883
  MqttClient({required String url, String? identifier, String? prefix}) {
    final uri = Uri.parse(url);
    final defaultValue = '[${prefix ?? 'mqtt_plus'}][${const Uuid().v4()}]';
    _identifier = identifier ?? defaultValue;
    _client = MqttServerClient.withPort(uri.host, _identifier, uri.port);
    _client.autoReconnect = true;
    _client.keepAlivePeriod = 60;
    _client.onAutoReconnect = onAutoReconnect;
    _client.onConnected = onConnected;
    _client.onDisconnected = onDisconnected;
    _client.onSubscribed = onSubscribed;
    _client.onUnsubscribed = onUnsubscribed;
  }

  MqttClientConnectionStatus? get connectionStatus => _client.connectionStatus;

  String get identifier => _identifier;

  /// Register a unique handler for every message type.
  void registerHandler(String type, MqttHandler handler) {
    final exist = _handlers.containsKey(type);
    assert(!exist, 'Handler for $type already registered');
    if (exist) {
      throw MqttException('Handler for $type already registered');
    }
    _handlers[type] = handler;
  }

  /// Unregister a unique handler for every message type.
  void unregisterHandle(String type, MqttHandler handler) {
    final exist = _handlers.containsKey(type);
    assert(exist, 'Handler for $type not registered');
    if (!exist) {
      throw MqttException('Handler for $type not registered');
    }
    _handlers.remove(type);
  }

  Future<void> connect([String? username, String? password]) async {
    await _client.connect(username, password);
    _client.updates?.listen(_handleReceived);
  }

  Future<void> subscribe(String topic) async {
    _client.subscribe(topic, MqttQos.atMostOnce);
    _topic = topic;
  }

  void unsubscribe(String topic) {
    _client.unsubscribe(topic);
    _topic = null;
  }

  void disconnect() {
    _client.disconnect();
  }

  void publish(Map<String, dynamic> payload) {
    try {
      final builder = MqttClientPayloadBuilder();
      payload['identifier'] = _identifier;
      final message = jsonEncode(payload);
      builder.addUTF8String(message);
      final topic = _topic ?? '';
      _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    } catch (error) {
      throw MqttException(error.toString());
    }
  }

  void _handleReceived(List<MqttReceivedMessage<MqttMessage>>? messages) {
    try {
      final message = messages!.first.payload as MqttPublishMessage;
      final convertedMessage = utf8.decode(message.payload.message);
      final payload = jsonDecode(convertedMessage);
      if (payload['identifier'] == _identifier) return;
      final type = payload['type'].toString();
      for (var entry in _handlers.entries) {
        if (type.startsWith(entry.key)) {
          entry.value.handle(payload);
          return;
        }
      }
      final exception = '$_identifier received unhandled message: $type';
      throw MqttException(exception);
    } catch (error) {
      throw MqttException(error.toString());
    }
  }
}
