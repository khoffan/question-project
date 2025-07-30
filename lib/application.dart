import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/services.dart' show rootBundle;

import 'package:csv/csv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_line_liff/flutter_line_liff.dart';
import 'package:questionnaire/cubit/answer_cubit.dart';
import 'package:questionnaire/cubit/form_cubit.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:questionnaire/model/question_model.dart';
import 'package:questionnaire/widget/comment_box_widget.dart';
import 'package:questionnaire/widget/custom_dropdown.dart';
import 'package:questionnaire/widget/question_widget.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  final ValueNotifier<bool> isSubmit = ValueNotifier<bool>(false);
  final ValueNotifier<String> _comment = ValueNotifier<String>("");
  bool _isReady = false;


  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    FlutterLineLiff.instance.ready.then((_) {
      debugPrint('Line ready');
      if (!FlutterLineLiff.instance.isLoggedIn) {
        FlutterLineLiff.instance.login();
      }
      setState(() {
        _isReady = true;
      });
    });

    questionList = widget.questions;
    final queryParams = Uri.base.queryParameters;
    final String? userId = queryParams['id'];
    final String? userName = queryParams['name'];
    final String? patientId = queryParams['patientId'];
    final String? patientName = queryParams['patientName'];
    _userId = userId ?? '12324';
    _userName = userName ?? 'test';
    _patientId = patientId ?? userId ?? '12324';
    _patientName = patientName ?? userName ?? 'test_patient';
    // print('Uri info: $_userId $_userName $_patientId $_patientName');
  }

  void _saveAnswer(String questionId, dynamic value, String? parentId) {
    final cubit = context.read<AnswerCubit>();

    if (value is Map<String, List<TapPointEntity>>) {
      cubit.saveAnswer(
        questionId: questionId.tr(),
        value: "",
        tapPoints: value,
        parentId: parentId,
      );
    } else {
      cubit.saveAnswer(
        questionId: questionId.tr(),
        value: value.toString(),
        parentId: parentId,
      );
    }
    cubit.saveLocal(questionId.tr(), value);
  }

  void _changeComment(String comment) {
    _comment.value = comment;
  }

  void _saveComment(String comment) {
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

  void _saveFormAnswer(Map<String, dynamic> ansMap) {
    final modifiedAnsMap = ansMap.map((key, value) {
      if (key.contains("comment")) {
        return MapEntry(key, value);
      } else if (value is String) {
        return MapEntry('question${key}_answer', value);
      } else if (value is Map<String, List<TapPointEntity>>) {
        return MapEntry('question${key}_answer', value.toString());
      }
      return MapEntry('question${key}_answer', '');
    });

    final combineMap = {
      "user_id": _userId,
      "user_name": _userName,
      "patient_id": _patientId,
      "patient_name": _patientName,
      ...modifiedAnsMap,
    };

    context.read<AnswerCubit>().saveFormAnswer(combineMap);
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLineReady) {
    //   final profile = FlutterLineLiff.instance.profile;
    //   print(profile);
    // }

    context.locale;
    if (!_isReady) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text("Loading...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    } else {
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
        body: FutureBuilder<Profile?>(
          future: FlutterLineLiff.instance.profile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final data = snapshot.data;
              _patientName = data?.displayName ?? '';
              return SingleChildScrollView(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ValueListenableBuilder(
                                  valueListenable: isSubmit,
                                  builder: (context, value, child) {
                                    if (value) {
                                      return _exportButton(context);
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                                Row(
                                  children: [
                                    Text("Patient ID: $_patientId"),
                                    const SizedBox(width: 8),
                                    Text("Patient Name: $_patientName"),
                                  ],
                                ),
                              ],
                            ),
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
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
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
                                isSubmit: isSubmit.value,
                                question: question,
                                onAnswer: _saveAnswer,
                              );
                            }),
                            const SizedBox(height: 30),
                            CommentBoxWidget(onComment: _changeComment),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                _saveComment(_comment.value);

                                isSubmit.value = true;

                                if (isSubmit.value) {
                                  final answers =
                                      context.read<AnswerCubit>().state;
                                  final sortedAnswers = sortedAnswerList(
                                    answers,
                                  );
                                  final ansMap = flattrenAnswerList(
                                    sortedAnswers,
                                  );
                                  _saveFormAnswer(ansMap);
                                  context
                                      .read<AnswerCubit>()
                                      .clearAllAnswerLocal();
                                }
                                setState(() {});

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    final navigate = Navigator.of(context);

                                    Future.delayed(
                                      const Duration(seconds: 2),
                                      () {
                                        if (navigate.canPop()) {
                                          navigate.pop();
                                        }
                                      },
                                    );

                                    return AlertDialog(
                                      title: const Text("Submit Form"),
                                      content: const Text("Submit form สำเร็จ"),
                                    );
                                  },
                                );
                              },
                              child: const Text("Submit"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }
  }

  Widget _exportButton(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 360) {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  final answers = context.read<AnswerCubit>().state;
                  final sortedAnswers = sortedAnswerList(answers);
                  final ansMap = flattrenAnswerList(sortedAnswers);

                  final modifiedAnsMap = ansMap.map((key, value) {
                    if (key.contains("comment")) {
                      return MapEntry(key, value);
                    } else if (value is String) {
                      return MapEntry('question${key}_answer', value);
                    } else if (value is Map<String, List<TapPointEntity>>) {
                      return MapEntry(
                        'question${key}_answer',
                        value.toString(),
                      );
                    }
                    return MapEntry('question${key}_answer', '');
                  });

                  final combineMap = {
                    "user_id": _userId,
                    "user_name": _userName,
                    "patient_id": _patientId,
                    "patient_name": _patientName,
                    ...modifiedAnsMap,
                  };
                  context.read<AnswerCubit>().saveAllAnswerLocal(
                    patientId: '',
                    answers: sortedAnswers,
                  );
                  downloadJsonFIle(
                    jsonEncode(combineMap),
                    "answer_map_${_patientName}_${DateTime.now()}.json",
                  );
                  context.read<AnswerCubit>().clearAllAnswerLocal();
                  isSubmit.value = false;
                  setState(() {});
                },
                child: Text('questionire.button.export_json'.tr()),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final answers = context.read<AnswerCubit>().state;
                  final sortedAnswers = sortedAnswerList(answers);
                  exportJson2Csv(answers: sortedAnswers);
                  isSubmit.value = false;
                  setState(() {});
                },
                child: Text('questionire.button.export_csv'.tr()),
              ),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final answers = context.read<AnswerCubit>().state;
                final sortedAnswers = sortedAnswerList(answers);
                context.read<AnswerCubit>().saveAllAnswerLocal(
                  patientId: _patientId,
                  answers: sortedAnswers,
                );
                final ansMap = flattrenAnswerList(sortedAnswers);

                final modifiedAnsMap = ansMap.map((key, value) {
                  if (key.contains("comment")) {
                    return MapEntry(key, value);
                  } else if (value is String) {
                    return MapEntry('question${key}_answer', value);
                  } else if (value is Map<String, List<TapPointEntity>>) {
                    return MapEntry('question${key}_answer', value.toString());
                  }
                  return MapEntry('question${key}_answer', '');
                });

                final combineMap = {
                  "user_id": _userId,
                  "user_name": _userName,
                  "patient_id": _patientId,
                  "patient_name": _patientName,
                  ...modifiedAnsMap,
                };
                // downloadJsonFIle(
                //   jsonEncode(combineMap),
                //   "answer_map_${_patientName}_${DateTime.now()}.json",
                // );
                // context.read<AnswerCubit>().clearAllAnswerLocal();
                // isSubmit.value = false;
                // setState(() {});

                _exportPdfWithPdfPackage(combineMap);
              },
              child: Text('questionire.button.export_json'.tr()),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final answers = context.read<AnswerCubit>().state;
                final sortedAnswers = sortedAnswerList(answers);
                context.read<AnswerCubit>().saveAllAnswerLocal(
                  patientId: _patientId,
                  answers: sortedAnswers,
                );
                exportJson2Csv(answers: sortedAnswers);

                isSubmit.value = false;
                setState(() {});
              },
              child: Text('questionire.button.export_csv'.tr()),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _exportPdfDocument(Map<String, dynamic> data) async {
  //   final fontData = await rootBundle.load('assets/fonts/THSarabunNew.ttf');
  //   // print(fontData.buffer.asUint8List());
  //   final buffer = fontData.buffer.asUint8List();

  //   final document = PdfDocument();
  //   PdfPage page = document.pages.add();
  //   final pageSize = page.getClientSize();
  //   final headerFont = PdfTrueTypeFont(buffer, 32, style: PdfFontStyle.bold);
  //   final subHeaderFont = PdfTrueTypeFont(buffer, 24, style: PdfFontStyle.bold);
  //   final font = PdfTrueTypeFont(buffer, 18);
  //   // final font = PdfStandardFont(PdfFontFamily.helvetica, 14);

  //   double y = 10;

  //   final header = PdfTextElement(
  //     text: "questionire.title".tr(),
  //     font: headerFont,
  //     format: PdfStringFormat(alignment: PdfTextAlignment.center),
  //   );
  //   final headerResult = header.draw(
  //     page: page,
  //     bounds: Rect.fromLTWH(10, y, pageSize.width - 20, double.infinity),
  //   );
  //   y = headerResult!.bounds.bottom + 4;

  //   final subHeader = PdfTextElement(
  //     text: "questionire.subtitle".tr(),
  //     font: subHeaderFont,
  //   );
  //   final subHeaderResult = subHeader.draw(
  //     page: page,
  //     bounds: Rect.fromLTWH(10, y, pageSize.width - 20, double.infinity),
  //   );
  //   y = subHeaderResult!.bounds.bottom + 4;

  //   final detail = PdfTextElement(text: "questionire.detail".tr(), font: font);
  //   final detailResult = detail.draw(
  //     page: page,
  //     bounds: Rect.fromLTWH(10, y, pageSize.width - 20, double.infinity),
  //   );
  //   y = detailResult!.bounds.bottom + 4;

  //   for (final q in widget.questions) {
  //     String mainKey = "question${q.numberQuestion.tr()}_answer";
  //     String questionText = q.question.tr();
  //     String answerText = "-";

  //     if (data.containsKey(mainKey) &&
  //         data[mainKey] != null &&
  //         data[mainKey].toString().isNotEmpty) {
  //       answerText = data[mainKey].toString();
  //     }

  //     // -- แสดงคำถามหลัก --
  //     final questionElement = PdfTextElement(
  //       text: "${q.numberQuestion.tr()}• $questionText",
  //       font: font,
  //     );
  //     final questionResult = questionElement.draw(
  //       page: page,
  //       bounds: Rect.fromLTWH(10, y, pageSize.width - 20, double.infinity),
  //     );
  //     y = questionResult!.bounds.bottom + 4;

  //     // -- แสดงคำตอบหลัก --
  //     final answerElement = PdfTextElement(
  //       text: "Answer: $answerText",
  //       font: font,
  //     );
  //     final answerResult = answerElement.draw(
  //       page: page,
  //       bounds: Rect.fromLTWH(20, y, pageSize.width - 30, double.infinity),
  //     );
  //     y = answerResult!.bounds.bottom + 8;

  //     // -- ถ้ามี subQuestion ให้วนแสดงต่อ --
  //     if (q.showSubQuestionOnYes) {
  //       for (final sq in q.subQuestions) {
  //         String subKey = "question${sq.numberQuestion.tr()}_answer";
  //         String subQuestionText = sq.question.tr();
  //         String subAnswerText = "-";

  //         if (data.containsKey(subKey) &&
  //             data[subKey] != null &&
  //             data[subKey].toString().isNotEmpty) {
  //           subAnswerText = data[subKey].toString();
  //         }

  //         final subQuestionElement = PdfTextElement(
  //           text: "${sq.numberQuestion.tr()}• $subQuestionText",
  //           font: font,
  //         );
  //         final subQuestionResult = subQuestionElement.draw(
  //           page: page,
  //           bounds: Rect.fromLTWH(10, y, pageSize.width - 20, double.infinity),
  //         );
  //         y = subQuestionResult!.bounds.bottom + 4;

  //         final subAnswerElement = PdfTextElement(
  //           text: "Answer: $subAnswerText",
  //           font: font,
  //         );
  //         final subAnswerResult = subAnswerElement.draw(
  //           page: page,
  //           bounds: Rect.fromLTWH(20, y, pageSize.width - 30, double.infinity),
  //         );
  //         y = subAnswerResult!.bounds.bottom + 8;

  //         // เช็ก overflow
  //         if (y > pageSize.height - 40) {
  //           page = document.pages.add();
  //           y = 10;
  //         }
  //       }
  //     }

  //     // เพิ่มระยะห่างก่อนคำถามถัดไป
  //     y += 8;

  //     if (y > pageSize.height - 40) {
  //       page = document.pages.add();
  //       y = 10;
  //     }
  //   }

  //   final bytes = await document.save();
  //   document.dispose();
  //   saveFile(bytes);
  // }

  Future<void> _exportPdfWithPdfPackage(Map<String, dynamic> data) async {
    final fontData = await rootBundle.load('assets/fonts/THSarabunNew.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                'questionire.title'.tr(),
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'questionire.subtitle'.tr(),
              style: pw.TextStyle(font: ttf, fontSize: 24),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'questionire.detail'.tr(),
              style: pw.TextStyle(font: ttf, fontSize: 18),
            ),
            pw.SizedBox(height: 10),

            // วนลูปคำถาม
            ...widget.questions.expand((q) {
              final mainKey = 'question${q.numberQuestion.tr()}_answer';
              final questionText = q.question.tr();
              final answerText =
                  data[mainKey]?.toString().isNotEmpty == true
                      ? data[mainKey].toString()
                      : '-';

              final widgets = <pw.Widget>[
                pw.Text(
                  "${q.numberQuestion.tr()} • $questionText",
                  style: pw.TextStyle(font: ttf, fontSize: 18),
                ),
                pw.Text(
                  "Answer: $answerText",
                  style: pw.TextStyle(font: ttf, fontSize: 16),
                ),
                pw.SizedBox(height: 10),
              ];

              if (q.showSubQuestionOnYes) {
                widgets.addAll(
                  q.subQuestions.map((sq) {
                    final subKey = 'question${sq.numberQuestion.tr()}_answer';
                    final subQuestionText = sq.question.tr();
                    final subAnswerText =
                        data[subKey]?.toString().isNotEmpty == true
                            ? data[subKey].toString()
                            : '-';

                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "${sq.numberQuestion.tr()} • $subQuestionText",
                          style: pw.TextStyle(font: ttf, fontSize: 16),
                        ),
                        pw.Text(
                          "Answer: $subAnswerText",
                          style: pw.TextStyle(font: ttf, fontSize: 14),
                        ),
                        pw.SizedBox(height: 8),
                      ],
                    );
                  }),
                );
              }

              return widgets;
            }),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    // ใช้ save หรือ share ตามต้องการ
    if (Platform.isAndroid || Platform.isIOS) {
      saveFileMobile(bytes);
    } else {
      saveFile(bytes);
    }
    await Printing.sharePdf(bytes: bytes, filename: 'questionnaire.pdf');
  }
}

Future<void> saveFile(List<int> byte) async {
  final blob = html.Blob([Uint8List.fromList(byte)]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final archor = html.AnchorElement(href: url)
    ..setAttribute("download", "answer_map_${DateTime.now()}.pdf");
  archor.click();
  html.Url.revokeObjectUrl(url);
}

Future<void> saveFileMobile(List<int> bytes) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/answer_map_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);

    await file.writeAsBytes(bytes);
    print('PDF saved to: $filePath');

    // เปิดไฟล์ทันที (optional)
    await OpenFile.open(filePath);
  } catch (e) {
    print('Error saving PDF: $e');
  }
}
