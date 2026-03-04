import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;

  Future<bool> connect() async {
    // Gunakan identifier unik agar tidak bentrok
    String identifier = 'gempara_mobile_${DateTime.now().millisecondsSinceEpoch}';
    client = MqttServerClient('broker.emqx.io', identifier);
    
    client.port = 1883; 
    client.secure = false; 
    client.keepAlivePeriod = 20;
    
    // Tambahkan baris ini agar koneksi lebih stabil di Android
    client.autoReconnect = true;
    client.resubscribeOnAutoReconnect = true;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(identifier) // Wajib disertakan di sini juga
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      print('Mencoba menghubungkan ke EMQX...');
      await client.connect();
    } catch (e) {
      print('Koneksi gagal: $e');
      client.disconnect();
      return false;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Berhasil Terhubung!');
      return true;
    } else {
      client.disconnect();
      return false;
    }
  }

  void publishPesan(String subTopic, String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      
      // Topik ini harus sama dengan yang Anda Subscribe di MQTTX
      String topic = 'gempara/mefby/$subTopic';
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Pesan terkirim ke $topic: $message');
    } else {
      print('Gagal mengirim: MQTT tidak aktif');
    }
  }
}
