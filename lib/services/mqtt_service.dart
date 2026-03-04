import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;

  Future<bool> connect() async {
    // Alamat Broker EMQX Publik
    client = MqttServerClient('broker.emqx.io', 'gempara_mobile_${DateTime.now().millisecondsSinceEpoch}');
    
    client.port = 1883; // Port standar (Non-SSL) agar mudah tembus
    client.secure = false; 
    client.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      return true;
    } catch (e) {
      client.disconnect();
      return false;
    }
  }

  void publishPesan(String subTopic, String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      // Kirim ke jalur mefby
      client.publishMessage('gempara/mefby/$subTopic', MqttQos.atLeastOnce, builder.payload!);
    }
  }
}
