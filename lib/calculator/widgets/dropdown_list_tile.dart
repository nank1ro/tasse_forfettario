import 'package:flutter/material.dart';

class DropdownListTile<T> extends StatefulWidget {
  const DropdownListTile({
    super.key,
    required this.labelText,
    this.value,
    required this.options,
    required this.onChanged,
    this.formatDisplayValue,
  });

  final String labelText;
  final T? value;
  final Iterable<T> options;
  final ValueChanged<T?> onChanged;
  final String Function(T value)? formatDisplayValue;

  @override
  State<DropdownListTile<T>> createState() => _DropdownListTileState<T>();
}

class _DropdownListTileState<T> extends State<DropdownListTile<T>> {
  late final FocusNode focusNode;
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode()
      ..addListener(() {
        setState(() {
          hasFocus = focusNode.hasFocus;
        });
      });
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return ListTile(
      focusColor: Colors.grey.shade200,
      title: Text(
        widget.labelText,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: hasFocus ? currentTheme.primaryColor : Colors.grey[700],
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: DropdownButton<T>(
          value: widget.value,
          dropdownColor: Colors.grey.shade200,
          focusColor: Colors.grey.shade200,
          isExpanded: true,
          focusNode: focusNode,
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
          items: widget.options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(
                    widget.formatDisplayValue?.call(option) ??
                        option.toString(),
                  ),
                ),
              )
              .toList(),
          onChanged: widget.onChanged,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
