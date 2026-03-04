// This is a basic Flutter widget test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart'; // Pastikan path ini benar

void main() {
  testWidgets('Renders the main screen and finds the title', (WidgetTester tester) async {
    // Bangun widget utama aplikasi Anda.
    await tester.pumpWidget(const GemparaApp());

    // Tunggu semua animasi atau frame selesai (jika ada).
    await tester.pumpAndSettle();

    // Verifikasi bahwa judul "SmartLock" ada di layar.
    // Ini adalah tes sederhana untuk memastikan UI utama berhasil dirender.
    expect(find.text('SmartLock'), findsOneWidget);

    // Anda juga bisa melakukan verifikasi lain, misalnya:
    // Memastikan tombol kontrol IoT ada (awalnya terlihat).
    expect(find.byIcon(Icons.videogame_asset_rounded), findsOneWidget);
  });
}
