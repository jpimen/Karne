import 'package:flutter/material.dart';

void main() {
  runApp(const LaboratoryApp());
}

class LaboratoryApp extends StatelessWidget {
  const LaboratoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Laboratory',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111111),
        colorScheme: ColorScheme.dark(primary: const Color(0xFFD4A017)),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'The Laboratory mobile app skeleton.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
