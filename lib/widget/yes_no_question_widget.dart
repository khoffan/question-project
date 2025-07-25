import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class YesNoQuestionWidget extends StatefulWidget {
  const YesNoQuestionWidget({
    super.key,
    required this.onYesNoSelected,
    this.initialYesNoValue,
  });
  final int? initialYesNoValue;
  final Function(int?) onYesNoSelected;

  @override
  State<YesNoQuestionWidget> createState() => _YesNoQuestionWidgetState();
}

class _YesNoQuestionWidgetState extends State<YesNoQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    context.locale;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double horizontalPadding =
            constraints.maxWidth * 0.05; // 5% ของความกว้าง
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Checkbox(
                value: widget.initialYesNoValue == 1,
                onChanged: (value) {
                  widget.onYesNoSelected(value == true ? 1 : null);
                },
              ),
              Text("questionire.yes_no.no".tr()),
              Checkbox(
                value: widget.initialYesNoValue == 2,
                onChanged: (value) {
                  widget.onYesNoSelected(value == true ? 2 : null);
                },
              ),
              Text("questionire.yes_no.yes".tr()),
            ],
          ),
        );
      },
    );
  }
}
