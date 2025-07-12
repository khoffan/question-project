import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questionnaire_project/cubit/answer_cubit.dart';
import 'package:questionnaire_project/widget/body_grid_canvas_widget.dart';
import 'package:questionnaire_project/widget/comment_box_widget.dart';
import 'package:questionnaire_project/widget/question_widget.dart';
import 'package:questionnaire_project/model/question_model.dart';

class Application extends StatefulWidget {
  const Application({super.key, required this.questions});
  final List<Question> questions;

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  late List<Question> questionList;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    questionList = widget.questions;
  }

  void _saveAnswer(String questionId, dynamic value) {
    context.read<AnswerCubit>().saveAnswer(questionId, value.toString());

    print(context.read<AnswerCubit>().state.answers);
  }

  void _saveComment(String comment) {
    context.read<AnswerCubit>().saveAnswer('comment', comment.toString());

    print(context.read<AnswerCubit>().state.answers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWidth = constraints.maxWidth > 1440;
              final double containerWidth =
                  isWidth ? 1260 : constraints.maxWidth;
              return Container(
                width: containerWidth,
                color: Colors.white,
                padding: const EdgeInsets.all(36),
                child: Column(
                  children: [
                    Text(
                      'PAIN QUESTIONNAIRE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                        left: 4,
                        right: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Text(
                        "You have been told by your doctor that you have a type of pain called \"Neuropathic pain\". This questionnaireasks you about this neuropathic pain and related unpleasant sensations (for example, tingling or numbness).Please make sure you think only about this pain and these types of sensations when you answer thesequestions, and not about any other pain or sensations you might feel.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      child: Text(
                        "Please answer the questions below by clearly marking an ‘x’ in the box ( ) that best describes your experience withneuropathic pain, thinking about the last 7 days, including today. Please make sure you answer each question.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        BodyGridCanvasWidget(
                          imagePath: 'assets/images/body_front.png',
                        ),
                        BodyGridCanvasWidget(
                          imagePath: 'assets/images/body_back.png',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ...questionList.map((question) {
                      return QuestionWidget(
                        question: question,
                        onAnswer: _saveAnswer,
                      );
                    }),
                    // QuestionWidget(
                    //   question: Question(
                    //     labelLeft: "No Pain",
                    //     labelRight: "Extreme Pain",
                    //     numberQuestion: "1",
                    //     question:
                    //         "Please select the number that best describes your pain on average in the last 7 days.",
                    //     questionHighlight: "your pain on average",
                    //   ),
                    //   onAnswer: _saveAnswer,
                    // ),
                    // const SizedBox(height: 18),
                    // QuestionWidget(
                    //   question: Question(
                    //     labelLeft: "No Pain",
                    //     labelRight: "Extreme Pain",
                    //     numberQuestion: "2",
                    //     question:
                    //         "Please select the number that best describes your pain on average in the last 7 days.",
                    //     questionHighlight: "your pain on average",
                    //   ),
                    //   onAnswer: _saveAnswer,
                    // ),

                    // const SizedBox(height: 18),
                    // QuestionWidget(
                    //   question: Question(
                    //     numberQuestion: "3",
                    //     question:
                    //         "Please choose the picture(s) that best describe(s) your experience of pain in the last 7 days.",
                    //     questionHighlight: "your experience of pain",
                    //     useChoice: true,
                    //   ),
                    //   onAnswer: _saveAnswer,
                    // ),
                    // const SizedBox(height: 18),
                    // QuestionWidget(
                    //   question: Question(
                    //     numberQuestion: "5a",
                    //     question:
                    //         "Please select the number that best describes your pain on average in the last 7 days.",
                    //     questionHighlight: "your pain on average",
                    //     isYesnoQuestion: true,
                    //     showSubQuestionOnYes: true,
                    //     subQuestions: [
                    //       Question(
                    //         labelLeft: "No burning sensation",
                    //         labelRight: "Extreme burning sensation",
                    //         numberQuestion: "5b",
                    //         question:
                    //             "Please select the number that best describes this burning sensation at its worst inthe last 7 days.",
                    //         questionHighlight:
                    //             "this burning sensation at its worst",
                    //       ),
                    //     ],
                    //   ),
                    //   onAnswer: _saveAnswer,
                    // ),
                    // const SizedBox(height: 18),
                    // QuestionWidget(
                    //   question: Question(
                    //     numberQuestion: "6a",
                    //     question:
                    //         "Have you experienced tingling in the last 7 days?",
                    //     questionHighlight: "tingling",
                    //     isYesnoQuestion: true,
                    //     showSubQuestionOnYes: true,
                    //     subQuestions: [
                    //       Question(
                    //         labelLeft: "No tingling",
                    //         labelRight: "Extreme tingling",
                    //         numberQuestion: "6b",
                    //         question:
                    //             "Please select the number that best describes this tingling at its worst in the last 7 days.",
                    //         questionHighlight: "this tingling at its worst",
                    //       ),
                    //     ],
                    //   ),
                    //   onAnswer: _saveAnswer,
                    // ),
                    // const SizedBox(height: 18),
                    // QuestionWidget(
                    //   question: Question(
                    //     numberQuestion: "7a",
                    //     question:
                    //         "Have you experienced a lack of sensation (numbness) in the last 7 days?",
                    //     questionHighlight: "a lack of sensation (numbness)",
                    //     isYesnoQuestion: true,
                    //     showSubQuestionOnYes: true,
                    //     subQuestions: [
                    //       Question(
                    //         labelLeft: "No numbness",
                    //         labelRight: "Extreme numbness",
                    //         numberQuestion: "7b",
                    //         question:
                    //             "Please select the number that best describes this lack of sensation (numbness) at its worst in the last 7 days.",
                    //         questionHighlight:
                    //             "this lack of sensation (numbness) at its worst",
                    //       ),
                    //       Question(
                    //         numberQuestion: "7c",
                    //         question:
                    //             "Have you experienced pain within a numb area in your body in the last 7 days?",
                    //         questionHighlight: "pain within a numb area",
                    //         isYesnoQuestion: true,
                    //         showSubQuestionOnYes: true,
                    //         subQuestions: [
                    //           Question(
                    //             labelLeft: "No pain",
                    //             labelRight: "Extreme pain",
                    //             numberQuestion: "7d",
                    //             question:
                    //                 "Please select the number that best describes this pain at its worst in the last 7 days.",
                    //             questionHighlight: "this pain at its worst",
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    //   onAnswer: _saveAnswer,
                    // ),
                    // const SizedBox(height: 18),
                    // QuestionWidget(
                    //   question: Question(
                    //     numberQuestion: "8a",
                    //     question:
                    //         "Have you experienced a painful electric-shock sensation in the last 7 days?",
                    //     questionHighlight: "a painful electric-shock sensation",
                    //     isYesnoQuestion: true,
                    //     showSubQuestionOnYes: true,
                    //     subQuestions: [
                    //       Question(
                    //         labelLeft: "No electric-shock sensation",
                    //         labelRight: "Extreme electric-shock sensation",
                    //         numberQuestion: "8b",
                    //         question:
                    //             "Please select the number that best describes this electric-shock sensation at its worst in the last 7 days.",
                    //         questionHighlight:
                    //             "this electric-shock sensation at its worst",
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // QuestionWidget(
                    //   question: Question(
                    //     numberQuestion: "9a",
                    //     question:
                    //         "Have you experienced itching in the last 7 days?",
                    //     questionHighlight: "itching",
                    //     isYesnoQuestion: true,
                    //     showSubQuestionOnYes: true,
                    //     subQuestions: [
                    //       Question(
                    //         numberQuestion: "9b",
                    //         question:
                    //             "Please select the number that best describes this itching at its worst in the last 7 days",
                    //         questionHighlight: "this itching at its worst",
                    //         labelLeft: "No itching",
                    //         labelRight: "Extreme itching",
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(height: 30),
                    CommentBoxWidget(onComment: _saveComment),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
