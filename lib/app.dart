import 'package:flutter/material.dart';
import 'pages/tela_inicial.dart';
import 'themes/app_theme.dart';

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cyberpunk,
      home: const TelaInicial(),
    );
  }
}
