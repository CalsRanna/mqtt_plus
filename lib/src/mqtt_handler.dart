/// Mqtt handler used to handle message from topic.
abstract class MqttHandler {
  void handle(dynamic payload);
}
