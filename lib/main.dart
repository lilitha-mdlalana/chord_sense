import 'package:flutter/material.dart';
import 'package:chord_sense/services/storage_service.dart';
import 'package:chord_sense/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await StorageService.recordOpen();
  runApp(const ChordSenseApp());
}

class ChordSenseApp extends StatelessWidget {
  const ChordSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChordSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5C4FCF)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
