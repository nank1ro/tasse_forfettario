import 'package:flutter/material.dart';
import 'package:tasse_forfettario/calculator/widgets/calculator_body.dart';

/// {@template calculator_page}
/// A description for CalculatorPage
/// {@endtemplate}
class CalculatorPage extends StatelessWidget {
  /// {@macro calculator_page}
  const CalculatorPage({super.key});

  /// The static route for CalculatorPage
  static Route<dynamic> route() {
    return MaterialPageRoute<dynamic>(builder: (_) => const CalculatorPage());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CalculatorBody(),
    );
  }
}
