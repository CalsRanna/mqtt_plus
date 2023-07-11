class MqttException implements Exception {
  const MqttException(this.message);

  final String message;
}
