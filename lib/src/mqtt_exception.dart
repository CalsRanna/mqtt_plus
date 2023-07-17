class MqttException implements Exception {
  const MqttException(String message) : _message = message;

  final String _message;

  String get message => _message;

  @override
  String toString() => message;
}
