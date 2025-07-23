import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questionnaire/cubit/answer_cubit.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:questionnaire/model/question_model.dart';
import 'package:questionnaire/widget/body_grid_canvas_widget.dart';
import 'package:questionnaire/widget/choice_answer_widget.dart';
import 'package:questionnaire/widget/level_pain_answer_widget.dart';
import 'package:questionnaire/widget/yes_no_question_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({super.key, required this.question, this.onAnswer});
  final Question question;
  final Function(String questionId, dynamic value, String? parentId)? onAnswer;

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  Map<String, int?> selectedPainValueMap = {};
  Map<String, int> selectedYesNoValue = {};
  Map<String, List<TapPointEntity>> allPoints = {"front": [], "back": []};

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.question.isYesnoQuestion) ...[
          _buildYesNoQuestion(widget.question, null),
          const SizedBox(height: 40),
          if (selectedYesNoValue[widget.question.numberQuestion] == 2 &&
              widget.question.showSubQuestionOnYes) ...[
            if (widget.question.subQuestions.isNotEmpty) ...[
              for (var question in widget.question.subQuestions) ...[
                if (question.isYesnoQuestion) ...[
                  _buildYesNoQuestion(question, widget.question.numberQuestion),
                  const SizedBox(height: 40),
                  if (question.showSubQuestionOnYes &&
                      selectedYesNoValue[question.numberQuestion] == 2 &&
                      question.subQuestions.isNotEmpty) ...[
                    for (var subQuestion in question.subQuestions) ...[
                      _buildLavelChoice(subQuestion, question.numberQuestion),
                      const SizedBox(height: 40),
                    ],
                  ],
                ] else ...[
                  _buildLavelChoice(question, widget.question.numberQuestion),
                  const SizedBox(height: 40),
                ],
              ],
            ] else
              const SizedBox(height: 40),
          ],
        ] else if (widget.question.useBodyGrid) ...[
          _bodyGrid(widget.question),
          const SizedBox(height: 40),
        ] else if (widget.question.useChoice) ...[
          _buildChoiceQuestion(widget.question),
          const SizedBox(height: 40),
        ] else ...[
          _buildLavelChoice(widget.question, null),
        ],
      ],
    );
  }

  Widget _bodyGrid(Question question) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 680) {
          return Column(
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16),
                  children: _buildHightlightText(
                    question,
                    question.questionHighlight,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              BodyGridCanvasWidget(
                imagePath: 'assets/images/body_front.png',
                questionId: question.numberQuestion.tr(),
                label: "front",
                onTap: (value) {
                  print("parent value front = ${value}");
                  setState(() {
                    value.forEach((key, newPoints) {
                      if (allPoints.containsKey(key)) {
                        allPoints[key]!.addAll(newPoints);
                      } else {
                        allPoints[key] = newPoints;
                      }
                    });
                  });
                },
              ),
              const SizedBox(height: 10),
              BodyGridCanvasWidget(
                imagePath: 'assets/images/body_back.png',
                questionId: question.numberQuestion.tr(),
                label: "back",
                onTap: (value) {
                  print("parent value back = ${value}");
                  setState(() {
                    value.forEach((key, newPoints) {
                      if (allPoints.containsKey(key)) {
                        allPoints[key]!.addAll(newPoints);
                      } else {
                        allPoints[key] = newPoints;
                      }
                    });
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed:
                    () => widget.onAnswer?.call(
                      question.numberQuestion.tr(),
                      allPoints,
                      null,
                    ),
                child: const Text("Save"),
              ),
            ],
          );
        }
        return Column(
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16),
                children: _buildHightlightText(
                  question,
                  question.questionHighlight,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BodyGridCanvasWidget(
                  imagePath: 'assets/images/body_front.png',
                  questionId: question.numberQuestion.tr(),
                  label: "front",
                  onTap: (value) {
                    setState(() {
                      value.forEach((key, newPoints) {
                        if (allPoints.containsKey(key)) {
                          allPoints[key]!.addAll(newPoints);
                        } else {
                          allPoints[key] = newPoints;
                        }
                      });
                    });
                  },
                ),
                BodyGridCanvasWidget(
                  imagePath: 'assets/images/body_back.png',
                  questionId: question.numberQuestion.tr(),
                  label: "back",
                  onTap: (value) {
                    setState(() {
                      value.forEach((key, newPoints) {
                        if (allPoints.containsKey(key)) {
                          allPoints[key]!.addAll(newPoints);
                        } else {
                          allPoints[key] = newPoints;
                        }
                      });
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed:
                  () => widget.onAnswer?.call(
                    question.numberQuestion.tr(),
                    allPoints,
                    null,
                  ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChoiceQuestion(Question question) {
    return FutureBuilder<dynamic>(
      future: context.read<AnswerCubit>().getAnswerLocal(
        question.numberQuestion.tr(),
      ),
      builder: (context, snapshot) {
        int choiceValue = 0;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final answer = snapshot.data;
          if (answer != null && answer is String) {
            choiceValue = int.parse(answer);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                selectedPainValueMap[question.numberQuestion] = choiceValue;
              });
            });
          }
        } else {
          choiceValue = selectedPainValueMap[question.numberQuestion] ?? 0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16),
                children: _buildHightlightText(
                  question,
                  question.questionHighlight,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ChoiceAnswerWidget(
              initialAnswerValue: choiceValue,
              onAnswer: (int? value) {
                setState(() {
                  selectedPainValueMap[question.numberQuestion] = value;
                });
                final painValue = selectedPainValueMap[question.numberQuestion];
                widget.onAnswer?.call(question.numberQuestion, painValue, null);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildYesNoQuestion(Question question, String? parentId) {
    return FutureBuilder<dynamic>(
      future: context.read<AnswerCubit>().getAnswerLocal(
        question.numberQuestion.tr(),
      ),
      builder: (context, snapshot) {
        int yesNoValue = 0;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final answer = snapshot.data;
          if (answer != null && answer is String) {
            yesNoValue = answer == "no" ? 1 : 2;
            // 👇 ป้องกันการ setState ซ้ำซ้อน
            if (!selectedYesNoValue.containsKey(question.numberQuestion)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  selectedYesNoValue[question.numberQuestion] = yesNoValue;
                });
              });
            }
          }
        } else {
          yesNoValue = selectedYesNoValue[question.numberQuestion] ?? 0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16),
                children: _buildHightlightText(
                  question,
                  question.questionHighlight,
                ),
              ),
            ),
            const SizedBox(height: 20),
            YesNoQuestionWidget(
              initialYesNoValue: yesNoValue,
              onYesNoSelected: (value) {
                setState(() {
                  selectedYesNoValue[question.numberQuestion] = value!;
                });
                final answer =
                    selectedYesNoValue[question.numberQuestion] == 1
                        ? "no"
                        : "yes";
                widget.onAnswer?.call(
                  question.numberQuestion,
                  answer,
                  parentId,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLavelChoice(Question question, String? parentId) {
    return FutureBuilder<dynamic>(
      future: context.read<AnswerCubit>().getAnswerLocal(
        question.numberQuestion.tr(),
      ),
      builder: (context, snapshot) {
        int painValue = 0;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final answer = snapshot.data;
          if (answer != null && answer is String) {
            painValue = int.parse(answer);
            // 👇 ป้องกันการ setState ซ้ำซ้อน
            if (!selectedPainValueMap.containsKey(question.numberQuestion)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  selectedPainValueMap[question.numberQuestion] = painValue;
                });
              });
            }
          }
        } else {
          painValue = selectedPainValueMap[question.numberQuestion] ?? 0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16),
                children: _buildHightlightText(
                  question,
                  question.questionHighlight,
                ),
              ),
            ),
            const SizedBox(height: 40),
            LavelPainWidget(
              labelLeft: question.labelLeft.tr(),
              labelRight: question.labelRight.tr(),
              onPainSelected: (value) {
                setState(() {
                  selectedPainValueMap[question.numberQuestion] = value;
                });
                final painValue = selectedPainValueMap[question.numberQuestion];
                widget.onAnswer?.call(
                  question.numberQuestion,
                  painValue,
                  parentId,
                );
              },
              initialPainValue: painValue,
            ),
          ],
        );
      },
    );
  }

  List<TextSpan> _buildHightlightText(
    Question question,
    List<HightLightText> hightlight,
  ) {
    List<TextSpan> spans = [];

    final String translatedQuestion = question.question.tr();

    spans.add(
      TextSpan(
        text: "${question.numberQuestion.tr()}. ",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );

    if (hightlight.isEmpty) {
      spans.add(TextSpan(text: translatedQuestion));
      return spans;
    }

    final highlightConfig =
        hightlight.map((e) {
          return HightLightText(
            text: e.text.tr(),
            underline: e.underline.map((u) => u.tr()).toList(),
          );
        }).toList();

    final List<String> translatedHighlightTexts =
        hightlight
            .map((h) => h.text.tr()) // แปลคีย์ของไฮไลต์แต่ละตัว
            .where((text) => text.isNotEmpty)
            .toList();

    final pattren = RegExp(
      translatedHighlightTexts.map((e) => RegExp.escape(e)).join("|"),
      caseSensitive: false,
    );

    int current = 0;
    final matchs = pattren.allMatches(translatedQuestion);

    for (final match in matchs) {
      if (match.start > current) {
        spans.add(
          TextSpan(text: translatedQuestion.substring(current, match.start)),
        );
      }

      final matchedText = translatedQuestion.substring(match.start, match.end);

      final hightlightText = highlightConfig.firstWhere(
        (e) => e.text.toLowerCase() == matchedText.toLowerCase(),
        orElse: () => HightLightText(text: matchedText),
      );

      if (hightlightText.underline.isEmpty) {
        spans.add(
          TextSpan(
            text: matchedText,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        );
      } else {
        final innerSpans = <TextSpan>[];

        final underlinePattren = RegExp(
          hightlightText.underline.map(RegExp.escape).join("|"),
          caseSensitive: false,
        );

        int currentInner = 0;
        final innerMatches = underlinePattren.allMatches(matchedText);

        for (final inner in innerMatches) {
          if (inner.start > currentInner) {
            innerSpans.add(
              TextSpan(text: matchedText.substring(currentInner, inner.start)),
            );
          }

          innerSpans.add(
            TextSpan(
              text: matchedText.substring(inner.start, inner.end),
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          );
          currentInner = inner.end;
        }
        if (currentInner < matchedText.length) {
          innerSpans.add(TextSpan(text: matchedText.substring(currentInner)));
        }
        spans.add(
          TextSpan(
            children: innerSpans,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        );
      }

      current = match.end;
    }

    if (current < translatedQuestion.length) {
      spans.add(TextSpan(text: translatedQuestion.substring(current)));
    }

    return spans;
  }
}
