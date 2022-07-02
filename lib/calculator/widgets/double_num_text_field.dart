import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tasse_forfettario/calculator/widgets/simple_text_field.dart';

/// A [TextField] that allows only double numbers to be entered.
class DoubleNumTextField extends StatelessWidget {
  const DoubleNumTextField({
    super.key,
    required this.labelText,
    required this.textEdititingController,
    required this.hintText,
    this.helperText,
  });

  final TextEditingController textEdititingController;
  final String labelText;
  final String hintText;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return SimpleTextField(
      labelText: labelText,
      helperText: helperText,
      showLabelAboveTextField: true,
      accentColor: context.colors.scheme.secondary,
      textEditingController: textEdititingController,
      hintText: hintText,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
      ],
    );
  }
}
