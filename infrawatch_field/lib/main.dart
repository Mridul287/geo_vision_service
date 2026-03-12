
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infrawatch_field/screens/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: InfraWatchFieldApp()));
}

class InfraWatchFieldApp extends StatelessWidget {
  const InfraWatchFieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfraWatch Field',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366f1),
          brightness: Brightness.dark,
          background: const Color(0xFF020817),
        ),
        scaffoldBackgroundColor: const Color(0xFF020817),
        cardTheme: const CardThemeData(
          color: Color(0xFF0f172a),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: Color(0xFF1e293b)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF0f172a),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFF1e293b)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFF1e293b)),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
