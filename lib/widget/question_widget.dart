import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questionnaire/cubit/answer_cubit.dart';
import 'package:questionnaire/datasource/form_local_datasouce.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:questionnaire/model/question_model.dart';
import 'package:questionnaire/widget/body_grid_canvas_widget.dart';
import 'package:questionnaire/widget/choice_answer_widget.dart';
import 'package:questionnaire/widget/level_pain_answer_widget.dart';
import 'package:questionnaire/widget/yes_no_question_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({
    super.key,
    required this.question,
    this.onAnswer,
    required this.isSubmit,
  });
  final Question question;
  final bool isSubmit;
  final Function(String questionId, dynamic value, String? parentId)? onAnswer;

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  Map<String, int?> selectedPainValueMap = {};
  Map<String, int> selectedYesNoValue = {};
  Map<String, List<TapPointEntity>> allPoints = {"front": [], "back": []};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AnswerCubit>().restoreAnswersFromLocal();
      }
    });
  }

  @override
  void didUpdateWidget(covariant QuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSubmit != widget.isSubmit) {
      Future.microtask(() {
        if (mounted) {
          context.read<AnswerCubit>().restoreAnswersFromLocal();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<AnswerCubit>().getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final data = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.question.isYesnoQuestion) ...[
                _buildYesNoQuestion(
                  context,
                  question: widget.question,
                  valueLocal: data?[widget.question.numberQuestion.tr()],
                ),
                const SizedBox(height: 40),
                if (selectedYesNoValue[widget.question.numberQuestion] == 2 &&
                    widget.question.showSubQuestionOnYes) ...[
                  if (widget.question.subQuestions.isNotEmpty) ...[
                    for (var question in widget.question.subQuestions) ...[
                      if (question.isYesnoQuestion) ...[
                        _buildYesNoQuestion(
                          context,
                          question: question,
                          valueLocal: data?[question.numberQuestion.tr()],
                          parentId: widget.question.numberQuestion,
                        ),
                        const SizedBox(height: 40),
                        if (question.showSubQuestionOnYes &&
                            selectedYesNoValue[question.numberQuestion] == 2 &&
                            question.subQuestions.isNotEmpty) ...[
                          for (var subQuestion in question.subQuestions) ...[
                            _buildLavelChoice(
                              context,
                              question: subQuestion,
                              valueLocal:
                                  data?[subQuestion.numberQuestion.tr()],
                              parentId: question.numberQuestion,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ],
                      ] else ...[
                        _buildLavelChoice(
                          context,
                          question: question,
                          valueLocal: data?[question.numberQuestion.tr()],
                          parentId: widget.question.numberQuestion,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ] else
                    const SizedBox(height: 40),
                ],
              ] else if (widget.question.useBodyGrid) ...[
                _bodyGrid(context, widget.question),
                const SizedBox(height: 40),
              ] else if (widget.question.useChoice) ...[
                _buildChoiceQuestion(
                  context,
                  question: widget.question,
                  valueLocal: data?[widget.question.numberQuestion.tr()],
                ),
                const SizedBox(height: 40),
              ] else ...[
                _buildLavelChoice(
                  context,
                  question: widget.question,
                  valueLocal: data?[widget.question.numberQuestion.tr()],
                ),
              ],
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _bodyGrid(BuildContext context, Question question) {
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
                  setState(() {
                    value.forEach((key, newPoints) {
                      if (allPoints.containsKey(key)) {
                        allPoints[key]!.addAll(newPoints);
                      } else {
                        allPoints[key] = newPoints;
                      }
                    });
                  });
                  widget.onAnswer?.call(
                    question.numberQuestion.tr(),
                    allPoints,
                    null,
                  );
                },
              ),
              const SizedBox(height: 10),
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
                  widget.onAnswer?.call(
                    question.numberQuestion.tr(),
                    allPoints,
                    null,
                  );
                },
              ),
              const SizedBox(height: 10),
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
                    widget.onAnswer?.call(
                      question.numberQuestion.tr(),
                      allPoints,
                      null,
                    );
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
                    widget.onAnswer?.call(
                      question.numberQuestion.tr(),
                      allPoints,
                      null,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  Widget _buildChoiceQuestion(
    BuildContext context, {
    required Question question,
    int? valueLocal,
  }) {
    if (!selectedPainValueMap.containsKey(question.numberQuestion)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedPainValueMap[question.numberQuestion] = valueLocal;
        });
      });
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
          initialAnswerValue:
              valueLocal ?? selectedPainValueMap[question.numberQuestion],
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
  }

  Widget _buildYesNoQuestion(
    BuildContext context, {
    required Question question,
    String? parentId,
    String? valueLocal,
  }) {
    if (!selectedYesNoValue.containsKey(question.numberQuestion)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedYesNoValue[question.numberQuestion] =
              valueLocal == "yes"
                  ? 2
                  : valueLocal == "no"
                  ? 1
                  : 0;
        });
      });
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
          initialYesNoValue:
              valueLocal == "yes"
                  ? 2
                  : valueLocal == "no"
                  ? 1
                  : selectedYesNoValue[question.numberQuestion],
          onYesNoSelected: (value) {
            setState(() {
              selectedYesNoValue[question.numberQuestion] = value!;
            });
            final answer =
                selectedYesNoValue[question.numberQuestion] == 1 ? "no" : "yes";
            widget.onAnswer?.call(question.numberQuestion, answer, parentId);
          },
        ),
      ],
    );
  }

  Widget _buildLavelChoice(
    BuildContext context, {
    required Question question,
    String? parentId,
    int? valueLocal,
  }) {
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
            widget.onAnswer?.call(question.numberQuestion, painValue, parentId);
          },
          initialPainValue:
              valueLocal ?? selectedPainValueMap[question.numberQuestion],
        ),
      ],
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
