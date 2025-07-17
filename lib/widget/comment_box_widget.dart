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
    return Column(
      children: [
        Text(
          "THANK YOU FOR YOUR PARTICIPATION",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "If you have any questions about this questionnaire or its contents, please ask the doctor who is treating you for your neuropathic pain.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Text(
          "If you have any comments about this questionnaire, please write them in the box below.",
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
                hintText: "Comments about the PainPredict questionnaire:",
                contentPadding: const EdgeInsets.all(8),
              ),
              onFieldSubmitted: widget.onComment,
              controller: _controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your comments";
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
