import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questionnaire/cubit/answer_cubit.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:questionnaire/model/question_model.dart';
import 'package:questionnaire/widget/comment_box_widget.dart';
import 'package:questionnaire/widget/custom_dropdown.dart';
import 'package:questionnaire/widget/question_widget.dart';
import 'package:universal_html/html.dart' as html;

class Application extends StatefulWidget {
  const Application({super.key, required this.questions});
  final List<Question> questions;

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  String _userId = '';
  String _userName = '';
  String _patientId = '';
  String _patientName = '';
  late List<Question> questionList;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    questionList = widget.questions;
    final queryParams = Uri.base.queryParameters;
    final String? userId = queryParams['id'];
    final String? userName = queryParams['name'];
    final String? patientId = queryParams['patientId'];
    final String? patientName = queryParams['patientName'];
    _userId = userId ?? '';
    _userName = userName ?? '';
    _patientId = patientId ?? userId ?? '';
    _patientName = patientName ?? userName ?? '';
    // print('Uri info: $_userId $_userName $_patientId $_patientName');
  }

  void _saveAnswer(String questionId, dynamic value, String? parentId) {
    final cubit = context.read<AnswerCubit>();

    if (value is Map<String, List<TapPointEntity>>) {
      cubit.saveAnswer(
        questionId: questionId,
        value: "",
        tapPoints: value,
        parentId: parentId,
      );
    } else {
      cubit.saveAnswer(
        questionId: questionId,
        value: value.toString(),
        parentId: parentId,
      );
    }
    cubit.saveLocal(questionId.tr(), value);
  }

  void _saveComment(String comment) {
    print(comment);
    context.read<AnswerCubit>().saveAnswer(
      questionId: 'comment',
      value: comment.toString(),
    );
    context.read<AnswerCubit>().saveLocal('comment', comment);
  }

  String exportAnswer2Json(List<AnswerModel> ans) {
    final result = {
      "form_id": "123456",
      "user_id": _userId,
      "user_name": _userName,
      "patian_id": _patientId,
      "patian_name": _patientName,
      "answers": ans.map((e) => e.toJson()).toList(),
    };
    return JsonEncoder.withIndent("  ").convert(result);
  }

  Map<String, dynamic> flattrenAnswerList(List<AnswerModel> list) {
    final Map<String, dynamic> map = {};

    void walk(List<AnswerModel> answers) {
      for (final ans in answers) {
        if (ans.answer != "") {
          map[ans.numberQuestion] = ans.answer;
        } else {
          map[ans.numberQuestion] = ans.tapPoints;
        }
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

  void downloadJsonFIle(String jsonString, String filename) async {
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

    final row = [
      _patientId,
      _patientName,
      ...ansMap.entries.map((entry) {
        final value = entry.value;

        // ถ้า value เป็นค่าว่าง และมี tapPoints ให้ใช้แทน
        if (value is String && value.isNotEmpty) {
          return value;
        }

        if (value is Map<String, List<TapPointEntity>> && value.isNotEmpty) {
          return value.map(
            (key, value) => MapEntry(key, value.map((e) => e.toMap()).toList()),
          );
        }

        return "";
      }),
      dateStr,
    ];

    final csvString = const ListToCsvConverter().convert([header, row]);

    downloadJsonFIle(csvString, "answer_${_patientName}_${DateTime.now()}.csv");
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAINPREDICT'),
        actions: [
          CustomDropdown(
            items: [
              Items(value: "en", label: "English"),
              Items(value: "th", label: "ไทย"),
            ],
            onChanged: (value) {
              context.setLocale(Locale(value!));
            },
            initialValue: "en",
          ),
        ],
      ),
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
                      'questionire.title'.tr(),
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
                      child: Text(
                        "questionire.subtitle".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      child: Text(
                        "questionire.detail".tr(),
                        style: TextStyle(fontSize: 16),
                      ),
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
                                  downloadJsonFIle(
                                    json,
                                    "answer_${_patientName}_${DateTime.now().millisecondsSinceEpoch}.json",
                                  );
                                },
                                child: Text(
                                  'questionire.button.export_json'.tr(),
                                ),
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
                                child: Text(
                                  'questionire.button.export_csv'.tr(),
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final answers =
                                    context.read<AnswerCubit>().state;
                                final sortedAnswers = sortedAnswerList(answers);
                                final json = exportAnswer2Json(sortedAnswers);
                                context.read<AnswerCubit>().saveAllAnswerLocal(
                                  patientId: _patientId,
                                  answers: sortedAnswers,
                                );
                                downloadJsonFIle(
                                  json,
                                  "answer_${_patientName}_${DateTime.now().millisecondsSinceEpoch}.json",
                                );
                                context
                                    .read<AnswerCubit>()
                                    .clearAllAnswerLocal();
                              },
                              child: Text(
                                'questionire.button.export_json'.tr(),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final answers =
                                    context.read<AnswerCubit>().state;
                                final sortedAnswers = sortedAnswerList(answers);
                                context.read<AnswerCubit>().saveAllAnswerLocal(
                                  patientId: _patientId,
                                  answers: sortedAnswers,
                                );
                                exportJson2Csv(answers: sortedAnswers);
                                context
                                    .read<AnswerCubit>()
                                    .clearAllAnswerLocal();
                              },
                              child: Text('questionire.button.export_csv'.tr()),
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
