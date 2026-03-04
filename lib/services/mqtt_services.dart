import 'dart:developer' as developer;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;
  bool isConnected = false;

  /// Fungsi untuk menghubungkan aplikasi ke Broker MQTT
  Future<bool> connect() async {
    // 1. Membuat ID unik setiap kali aplikasi dibuka
    String identifier = 'gempara_app_${DateTime.now().millisecondsSinceEpoch}';

    // 2. Inisialisasi Broker (Menggunakan EMQX Public Broker)
    // Jika nanti Anda menggunakan broker pribadi, ganti alamat ini.
    client = MqttServerClient('broker.emqx.io', identifier);

    // 3. Konfigurasi Standar untuk Android/iOS
    client.port = 1883; // Port standar TCP
    client.keepAlivePeriod = 20;
    client.secure = false; // Set true jika menggunakan SSL/TLS (Port 8883)
    client.autoReconnect = true; // Otomatis menyambung kembali jika internet drop

    // Menampilkan log di konsol IDX/VS Code untuk mempermudah pengecekan
    client.logging(on: true);

    // 4. Pengaturan Pesan Koneksi (LWT - Last Will and Testament)
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(identifier)
        .startClean() // Memulai sesi bersih
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    // 5. Proses Mencoba Terhubung
    try {
      developer.log('MQTT: Menghubungkan ke broker...');
      await client.connect();
    } catch (e, s) {
      developer.log('MQTT ERROR: Gagal terhubung', error: e, stackTrace: s);
      client.disconnect();
      isConnected = false;
      return false;
    }

    // 6. Cek Status Akhir
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      developer.log('MQTT: BERHASIL TERHUBUNG');
      isConnected = true;
      return true;
    } else {
      developer.log('MQTT: GAGAL - Status: ${client.connectionStatus!.state}');
      client.disconnect();
      isConnected = false;
      return false;
    }
  }

  /// Fungsi untuk mengirim pesan ke topik gempara/mefby/
  void publishPesan(String subTopic, String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      // Menggabungkan prefix utama dengan sub-topic tombol
      String fullTopic = 'gempara/mefby/$subTopic';

      client.publishMessage(fullTopic, MqttQos.atLeastOnce, builder.payload!);
      developer.log('MQTT SEND: [$fullTopic] -> $message');
    } else {
      developer.log('MQTT ERROR: Tidak bisa mengirim pesan, status OFFLINE');
    }
  }

  /// Fungsi untuk memutus koneksi secara bersih
  void disconnect() {
    client.disconnect();
    isConnected = false;
    developer.log('MQTT: Koneksi diputuskan');
  }
}
