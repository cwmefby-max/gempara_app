import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;

  Future<bool> connect() async {
    // ID Unik sangat penting (Sesuai dokumentasi HiveMQ)
    String identifier = 'gempara_mobile_${DateTime.now().millisecondsSinceEpoch}';
    
    // Inisialisasi sesuai panduan
    client = MqttServerClient('1ff784315caf430e9d7329650ca769b5.s1.eu.hivemq.cloud', identifier);
    
    client.port = 8883; 
    client.secure = true; // Mengaktifkan TLS
    client.setProtocolV311(); // Protokol standar HiveMQ Cloud
    client.keepAlivePeriod = 20;

    // Bagian ini wajib untuk Android agar tidak memblokir sertifikat SSL HiveMQ
    client.onBadCertificate = (dynamic cert) => true;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(identifier)
        .authenticateAs('mefby', 'Arema1987.') // Pastikan ini sama dengan di Access Management
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      print('Mencoba koneksi sesuai panduan HiveMQ...');
      await client.connect();
    } catch (e) {
      print('Gagal koneksi: $e');
      client.disconnect();
      return false;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('BERHASIL TERHUBUNG!');
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
    }
  }
}
