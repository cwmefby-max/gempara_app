import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;

  Future<bool> connect() async {
    // GANTI: Masukkan Cluster URL HiveMQ Anda (contoh: xxxxx.s1.eu.hivemq.cloud)
    client = MqttServerClient('1ff784315caf430e9d7329650ca769b5.s1.eu.hivemq.cloud', 'flutter_client');
    
    client.port = 8883; 
    client.secure = true;
    client.logging(on: false);
    client.keepAlivePeriod = 20;

    // Menangani keamanan koneksi (Penting untuk HiveMQ Cloud)
    client.onBadCertificate = (dynamic cert) => true;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('gempara_mobile_id')
        .authenticateAs('mefby', 'Arema1987.') // GANTI: Username & Password HiveMQ
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      print('Menghubungkan ke HiveMQ...');
      await client.connect();
    } catch (e) {
      print('Koneksi Gagal: $e');
      client.disconnect();
      return false;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Koneksi Berhasil!');
      return true;
    } else {
      client.disconnect();
      return false;
    }
  }

  void publishPesan(String topic, String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Pesan Terkirim: $message ke $topic');
    } else {
      print('Gagal mengirim: MQTT tidak terkoneksi');
    }
  }
}
