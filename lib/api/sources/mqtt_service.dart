import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';

class MQTTService {
  final _client = MqttServerClient.withPort(
    Session.currentConfig.mqttServer,
    DateTime.now().millisecondsSinceEpoch.toString(),
    1882,
  );

  Stream<Map<String, Map<String, dynamic>>>? get updates =>
      _client.updates?.map((messages) {
        var results = <String, Map<String, dynamic>>{};
        for (var msg in messages) {
          if (msg.payload is MqttPublishMessage) {
            results[msg.topic] = jsonDecode(
                MqttPublishPayload.bytesToStringAsString(
                    (msg.payload as MqttPublishMessage).payload.message));
          }
        }
        return results;
      });

  bool get isConnected =>
      _client.connectionStatus?.state == MqttConnectionState.connected;

  final _connectionState = BehaviorSubject<MqttConnectionState?>();
  Stream<MqttConnectionState?> get connectionState => _connectionState.stream;

  MQTTService() {
    _client.logging(on: true);
    _client.setProtocolV311();
    _client.keepAlivePeriod = 20;
    _client.disconnectOnNoResponsePeriod = 1;

    _client.onConnected = _onConnected;

    _client.autoReconnect = true;
    _client.onAutoReconnect = _onAutoReconnect;
    _client.onAutoReconnected = _onAutoReconnected;

    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.onUnsubscribed = _onUnsubscribed;

    _client.onDisconnected = _onDisconnected;
  }

  Future<void> connect() async {
    try {
      await _client.connect('vgrow', 'lamiwe123456');
    } catch (e) {
      _client.disconnect();
    }

    if (_client.connectionStatus?.state != MqttConnectionState.connected) {
      _client.disconnect();
    }
  }

  void disconnect() {
    _client.disconnect();
  }

  void subscribe(String topic) {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      _client.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void unsubscribe(String topic) {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      _client.unsubscribe(topic);
    }
  }

  void _onConnected() {
    print("--------- ON CONNECTED");
    _updateConnectionState();
  }

  void _onAutoReconnect() {
    print("--------- ON AUTO RECONNECT");
    _updateConnectionState();
  }

  void _onAutoReconnected() {
    print("--------- ON AUTO RECONNECTED");
    _updateConnectionState();
  }

  void _onSubscribed(String topic) {
    print("-------- ON SUBSCRIBED: $topic");
  }

  void _onSubscribeFail(String topic) {
    print("--------- ON SUBSCRIBE FAIL");
  }

  void _onUnsubscribed(String? topic) {
    print("--------- ON UNSUBSCRIBED");
  }

  void _onDisconnected() {
    print("--------- ON DISCONNECTED");
    _updateConnectionState();
  }

  void _updateConnectionState() {
    _connectionState.add(_client.connectionStatus?.state);
  }
}
