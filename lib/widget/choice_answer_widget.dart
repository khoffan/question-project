import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ChoiceAnswerWidget extends StatefulWidget {
  const ChoiceAnswerWidget({super.key, this.onAnswer, this.initialAnswerValue});

  final ValueChanged<int?>? onAnswer;
  final int? initialAnswerValue;

  @override
  State<ChoiceAnswerWidget> createState() => _ChoiceAnswerWidgetState();
}

class _ChoiceAnswerWidgetState extends State<ChoiceAnswerWidget> {
  int? _selectedChoiceValue;

  @override
  void initState() {
    super.initState();
    _selectedChoiceValue = widget.initialAnswerValue;
  }

  void _handleChoiceSelection(int value) {
    setState(() {
      _selectedChoiceValue = value;
    });
    widget.onAnswer?.call(_selectedChoiceValue!);
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontalPadding =
            constraints.maxWidth * 0.05; // 5% ของความกว้าง
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChoice(
                image: "slight",
                text: "questionire.3.choice.1".tr(),
                number: 1,
                onAnswer: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _buildChoice(
                image: "large",
                text: "questionire.3.choice.2".tr(),
                number: 2,
                onAnswer: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _buildChoice(
                image: "pain_peak",
                text: "questionire.3.choice.3".tr(),
                number: 3,
                onAnswer: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _buildChoice(
                image: "pain_between",
                text: "questionire.3.choice.4".tr(),
                number: 4,
                onAnswer: _handleChoiceSelection,
              ),
              const SizedBox(height: 16),
              _buildChoice(
                image: "",
                text: "questionire.3.choice.5".tr(),
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
    final maxWidth = MediaQuery.of(context).size.width;
    if (maxWidth <= 400) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _selectedChoiceValue == number,
            onChanged: (_) => _handleChoiceSelection(number),
          ),
          if (image.isNotEmpty) const SizedBox(height: 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image.isNotEmpty && image != "") ...[
                SizedBox(
                  width: 200,
                  height: 100,
                  child: Image.asset(
                    "assets/images/$image.png",
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 5),
              ],
              Text(text),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Checkbox(
            value: _selectedChoiceValue == number,
            onChanged: (_) => _handleChoiceSelection(number),
          ),
          const SizedBox(width: 30),
          maxWidth <= 680
              ? Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (image.isNotEmpty && image != "") ...[
                      SizedBox(
                        width: 200,
                        height: 100,
                        child: Image.asset(
                          "assets/images/$image.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(text),
                  ],
                ),
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (image.isNotEmpty && image != "") ...[
                    SizedBox(
                      width: 200,
                      height: 100,
                      child: Image.asset(
                        "assets/images/$image.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Text(text),
                ],
              ),
        ],
      );
    }
  }
}
