import 'package:flutter/material.dart';
import 'package:tasse_forfettario/calculator/calculator.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            fontSize: 16,
          ),
          bodyText2: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      home: const CalculatorPage(),
    );
  }
}
