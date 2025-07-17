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
    widget.onAnswer?.call(_selectedChoiceValue!);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontalPadding =
            constraints.maxWidth * 0.05; // 5% ของความกว้าง
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              _buildChoice(
                image: "slight",
                text: "Constant pain with slight fluctuations",
                number: 1,
                onAnswer: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _buildChoice(
                image: "large",
                text: "Constant pain with large fluctuations",
                number: 2,
                onAnswer: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _buildChoice(
                image: "pain_peak",
                text: "Constant pain with pain peaks",
                number: 3,
                onAnswer: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _buildChoice(
                image: "pain_between",
                text: "Pain peaks without pain between them",
                number: 4,
                onAnswer: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _buildChoice(
                image: "",
                text: "None of these pictures describe my pain",
                number: 5,
                onAnswer: _handleChoiceSelection,
              ),
            ],
          ),
        );
      },
    );
  }

  _buildChoice({
    required String image,
    required String text,
    required int number,
    required Function(int) onAnswer,
  }) {
    return Row(
      children: [
        Checkbox(
          value: _selectedChoiceValue == number,
          onChanged: (_) => _handleChoiceSelection(number),
        ),
        const SizedBox(width: 30),
        if (image.isNotEmpty && image != "") ...[
          SizedBox(
            width: 200,
            height: 100,
            child: Image.asset("assets/images/$image.png", fit: BoxFit.cover),
          ),
        ],
        const SizedBox(width: 16),
        Text(text),
      ],
    );
  }
}
