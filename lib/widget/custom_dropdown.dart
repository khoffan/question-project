import 'package:flutter/material.dart';

class Items {
  final String value;
  final String label;

  Items({required this.value, required this.label});
}

class CustomDropdown extends StatefulWidget {
  final List<Items> items;
  final ValueChanged<String?> onChanged;
  final String? initialValue;
  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: DropdownButtonFormField<String>(
        value: widget.initialValue,
        isDense: true,
        dropdownColor: Colors.white,
        items:
            widget.items.map((item) {
              return DropdownMenuItem(
                value: item.value,
                child: Text(item.label),
              );
            }).toList(),
        onChanged: widget.onChanged,
      ),
    );
  }
}
