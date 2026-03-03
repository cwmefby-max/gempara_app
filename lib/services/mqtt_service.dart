import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;

  Future<bool> connect() async {
    // ID unik menggunakan timestamp agar tidak bentrok dengan perangkat lain
    String clientIdentifier = 'gempara_app_${DateTime.now().millisecondsSinceEpoch}';
    
    // Pastikan URL bersih tanpa mqtt://
    client = MqttServerClient('1ff784315caf430e9d7329650ca769b5.s1.eu.hivemq.cloud', clientIdentifier);
    
    client.port = 8883; 
    client.secure = true;
    client.logging(on: true); // Aktifkan log untuk melihat proses di console
    client.keepAlivePeriod = 20;

    // Sangat penting untuk HiveMQ Cloud agar SSL tidak ditolak Android
    client.onBadCertificate = (dynamic cert) => true;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .authenticateAs('mefby', 'Arema1987.') // Pastikan user & pass ini sesuai di Access Management
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      print('Menghubungkan ke HiveMQ dengan ID: $clientIdentifier');
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
      print('Status Koneksi: ${client.connectionStatus!.state}');
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
