import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);
  runApp(QuitSmokingApp(storage: storage));
}

class QuitSmokingApp extends StatelessWidget {
  final StorageService storage;

  const QuitSmokingApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '禁煙記録',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C896),
          brightness: Brightness.dark,
          primary: const Color(0xFF00C896),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1419),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A2332),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF2D3A4D)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF0F1419),
          foregroundColor: Color(0xFFE6EDF3),
        ),
      ),
      home: HomeScreen(storage: storage),
    );
  }
}
