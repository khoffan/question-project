import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CommentBoxWidget extends StatefulWidget {
  const CommentBoxWidget({super.key, this.onComment});
  final ValueChanged<String>? onComment;

  @override
  State<CommentBoxWidget> createState() => _CommentBoxWidgetState();
}

class _CommentBoxWidgetState extends State<CommentBoxWidget> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Column(
      children: [
        Text(
          "questionire.end.title".tr(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "questionire.end.detail".tr(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Text(
          "questionire.end.subdetail".tr(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Container(
            width: 650,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: TextFormField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "questionire.end.text_box.title".tr(),
                contentPadding: const EdgeInsets.all(8),
              ),
              onFieldSubmitted: widget.onComment,
              controller: _controller,
            ),
          ),
        ),
      ],
    );
  }
}
