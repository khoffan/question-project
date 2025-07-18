import 'package:flutter/material.dart';

class ChoiceAnswerWidget extends StatefulWidget {
  const ChoiceAnswerWidget({super.key, this.onAnswer});

  final ValueChanged<int?>? onAnswer;

  @override
  State<ChoiceAnswerWidget> createState() => _ChoiceAnswerWidgetState();
}

class _ChoiceAnswerWidgetState extends State<ChoiceAnswerWidget> {
  int? _selectedChoiceValue;

  void _handleChoiceSelection(int value) {
    setState(() {
      _selectedChoiceValue = value;
    });
    widget.onAnswer?.call(_selectedChoiceValue);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontalPadding = constraints.maxWidth * 0.05;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChoiceOption(
                image: "slight",
                text: "Constant pain with slight fluctuations",
                number: 1,
                isSelected: _selectedChoiceValue == 1,
                onSelected: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _ChoiceOption(
                image: "large",
                text: "Constant pain with large fluctuations",
                number: 2,
                isSelected: _selectedChoiceValue == 2,
                onSelected: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _ChoiceOption(
                image: "pain_peak",
                text: "Constant pain with pain peaks",
                number: 3,
                isSelected: _selectedChoiceValue == 3,
                onSelected: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _ChoiceOption(
                image: "pain_between",
                text: "Pain peaks without pain between them",
                number: 4,
                isSelected: _selectedChoiceValue == 4,
                onSelected: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _ChoiceOption(
                image: "",
                text: "None of these pictures describe my pain",
                number: 5,
                isSelected: _selectedChoiceValue == 5,
                onSelected: _handleChoiceSelection,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChoiceOption extends StatelessWidget {
  const _ChoiceOption({
    required this.image,
    required this.text,
    required this.number,
    required this.isSelected,
    required this.onSelected,
  });

  final String image;
  final String text;
  final int number;
  final bool isSelected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final double maxWidth = MediaQuery.of(context).size.width;

    Widget imageWidget =
        image.isNotEmpty
            ? SizedBox(
              width: 200,
              height: 100,
              child: Image.asset("assets/images/$image.png", fit: BoxFit.cover),
            )
            : const SizedBox.shrink(); // Use SizedBox.shrink() for empty space

    return InkWell(
      onTap: () => onSelected(number),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(value: isSelected, onChanged: (_) => onSelected(number)),
          const SizedBox(width: 16), // Consistent spacing

          if (maxWidth <= 400)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageWidget,
                  if (image.isNotEmpty) const SizedBox(height: 8),
                  Text(text),
                ],
              ),
            )
          else if (maxWidth <= 680)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageWidget,
                  if (image.isNotEmpty) const SizedBox(height: 8),
                  Text(text),
                ],
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageWidget,
                if (image.isNotEmpty) const SizedBox(width: 16),
                Text(text),
              ],
            ),
        ],
      ),
    );
  }
}
