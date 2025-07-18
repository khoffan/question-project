import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questionnaire/cubit/answer_cubit.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:questionnaire/model/question_model.dart';
import 'package:questionnaire/widget/body_grid_canvas_widget.dart';
import 'package:questionnaire/widget/comment_box_widget.dart';
import 'package:questionnaire/widget/question_widget.dart';
import 'package:universal_html/html.dart' as html;


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

  void _saveAnswer(String questionId, dynamic value, String? parentId) {
    context.read<AnswerCubit>().saveAnswer(
      questionId: questionId,
      value: value.toString(),
      parentId: parentId,
    );
  }

  void _saveComment(String comment) {
    context.read<AnswerCubit>().saveAnswer(
      questionId: 'comment',
      value: comment.toString(),
    );
  }

  String exportAnswer2Json(List<AnswerModel> ans) {
    final result = {
      "form_id": "123456",
      "patian_id": "user123",
      "user_id": "user123",
      "patian_name": "John Doe",
      "answers": ans.map((e) => e.toJson()).toList(),
    };
    return JsonEncoder.withIndent("  ").convert(result);
  }

  Map<String, String> flattrenAnswerList(List<AnswerModel> list) {
    final Map<String, String> map = {};

    void walk(List<AnswerModel> answers) {
      for (final ans in answers) {
        map[ans.numberQuestion] = ans.answer;
        if (ans.subAnswers.isNotEmpty) {
          walk(ans.subAnswers);
        }
      }
    }

    walk(list);
    return map;
  }

  int compareNumberQuestion(String a, String b) {
    final regexp = RegExp(r'^(\d+)([a-zA-Z]*)$');
    final matchA = regexp.firstMatch(a);
    final matchB = regexp.firstMatch(b);

    if (matchA == null || matchB == null) return a.compareTo(b);

    final int numberA = int.parse(matchA.group(1)!);
    final int numberB = int.parse(matchB.group(1)!);

    if (numberA != numberB) return numberA.compareTo(numberB);

    final String letterA = matchA.group(2) ?? '';
    final String letterB = matchB.group(2) ?? '';

    return letterA.compareTo(letterB);
  }

  List<AnswerModel> sortedAnswerList(List<AnswerModel> list) {
    final sorted = List<AnswerModel>.from(list);

    sorted.sort(
      (a, b) => compareNumberQuestion(a.numberQuestion, b.numberQuestion),
    );

    for (final ans in list) {
      if (ans.subAnswers.isNotEmpty) {
        ans.subAnswers.sort(
          (a, b) => compareNumberQuestion(a.numberQuestion, b.numberQuestion),
        );
      }
    }

    return sorted;
  }

  void downloadJsonFIle(
    String jsonString, [
    String filename = "answer.json",
  ]) async {
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final archor = html.AnchorElement(href: url)
      ..setAttribute("download", filename);
    archor.click();
    html.Url.revokeObjectUrl(url);
  }

  void exportJson2Csv({required List<AnswerModel> answers}) async {
    final now = DateTime.now();
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final ansMap = flattrenAnswerList(answers);

    final header = ['patianId', 'patianName', ...ansMap.keys, "date"];

    final row = ["user123", "John Doe", ...ansMap.values, dateStr];

    final csvString = const ListToCsvConverter().convert([header, row]);

    downloadJsonFIle(csvString, "answer.csv");
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
              return Container(
                constraints: BoxConstraints(maxWidth: 1260),
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth <= 680) {
                          return Column(
                            children: [
                              BodyGridCanvasWidget(
                                imagePath: 'assets/images/body_front.png',
                              ),
                              const SizedBox(height: 10),
                              BodyGridCanvasWidget(
                                imagePath: 'assets/images/body_back.png',
                              ),
                            ],
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BodyGridCanvasWidget(
                              imagePath: 'assets/images/body_front.png',
                            ),
                            BodyGridCanvasWidget(
                              imagePath: 'assets/images/body_back.png',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    ...questionList.map((question) {
                      return QuestionWidget(
                        question: question,
                        onAnswer: _saveAnswer,
                      );
                    }),
                    const SizedBox(height: 30),
                    CommentBoxWidget(onComment: _saveComment),
                    const SizedBox(height: 30),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth <= 360) {
                          return Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  final answers =
                                      context.read<AnswerCubit>().state;
                                  final sortedAnswers = sortedAnswerList(
                                    answers,
                                  );
                                  final json = exportAnswer2Json(sortedAnswers);
                                  downloadJsonFIle(json);
                                },
                                child: Text('Export json file'),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  final answers =
                                      context.read<AnswerCubit>().state;
                                  final sortedAnswers = sortedAnswerList(
                                    answers,
                                  );
                                  exportJson2Csv(answers: sortedAnswers);
                                },
                                child: Text('Export csv file'),
                              ),
                            ],
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                final answers =
                                    context.read<AnswerCubit>().state;
                                final sortedAnswers = sortedAnswerList(answers);
                                final json = exportAnswer2Json(sortedAnswers);
                                downloadJsonFIle(json);
                              },
                              child: Text('Export json file'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final answers =
                                    context.read<AnswerCubit>().state;
                                final sortedAnswers = sortedAnswerList(answers);
                                exportJson2Csv(answers: sortedAnswers);
                              },
                              child: Text('Export csv file'),
                            ),
                          ],
                        );
                      },
                    ),
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
