import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  bool isConnected = false;

  Future<bool> connect() async {
    // 1. Buat Client ID Unik agar tidak saling 'tendang' dengan MQTTX Laptop
    String identifier = 'gempara_mobile_${DateTime.now().millisecondsSinceEpoch}';
    
    // 2. Setting Alamat Broker EMQX
    client = MqttServerClient('broker.emqx.io', identifier);
    
    // 3. Konfigurasi Port & Protokol
    client.port = 1883; // Port standar untuk Mobile/ESP32
    client.keepAlivePeriod = 20;
    client.secure = false; // Non-SSL agar koneksi lebih cepat & ringan
    client.autoReconnect = true; // Otomatis konek jika sinyal HP drop

    // Menampilkan log di konsol (sangat membantu saat debug di komputer)
    client.logging(on: true);

    // 4. Setup Pesan Koneksi
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(identifier)
        .startClean() // Membersihkan sesi lama
        .withWillQos(MqttQos.atLeastOnce);
    
    client.connectionMessage = connMessage;

    try {
      print('Mencoba koneksi ke EMQX...');
      await client.connect();
    } catch (e) {
      print('Gagal Koneksi: $e');
      client.disconnect();
      return false;
    }

    // Cek apakah benar-benar terhubung
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('BERHASIL TERHUBUNG KE BROKER');
      isConnected = true;
      return true;
    } else {
      print('KONEKSI GAGAL - Status: ${client.connectionStatus!.state}');
      client.disconnect();
      isConnected = false;
      return false;
    }
  }

  // 5. Fungsi Kirim Pesan (Publish) ke Topik gempara/mefby
  void publishPesan(String subTopic, String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      
      // Menggabungkan topik utama dengan sub-topik (misal: alarm, lock, dll)
      String fullTopic = 'gempara/mefby/$subTopic';
      
      client.publishMessage(fullTopic, MqttQos.atLeastOnce, builder.payload!);
      print('Pesan Terkirim: $message ke Topik: $fullTopic');
    } else {
      print('Gagal Kirim: Client tidak terhubung ke MQTT');
    }
  }

  void disconnect() {
    client.disconnect();
    isConnected = false;
  }
}
