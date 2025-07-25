import 'package:equatable/equatable.dart';

class FormModel {
  final String formId;
  final String userId;
  final List<Question> questions;

  const FormModel({
    required this.formId,
    required this.userId,
    required this.questions,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      formId: json['form_id'] ?? "",
      userId: json['user_id'] ?? "",
      questions:
          json['questions'] != null
              ? List<Question>.from(
                json['questions'].map((x) => Question.fromJson(x)),
              )
              : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'form_id': formId,
      'user_id': userId,
      'questions': questions.map((x) => x.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'FormModel(formId: $formId, userId: $userId, questions: $questions)';
  }
}

class Question extends Equatable {
  final String numberQuestion;
  final String question;
  final List<HightLightText> questionHighlight;
  final String labelLeft;
  final String labelRight;
  final bool isYesnoQuestion;
  final bool useChoice;
  final bool showSubQuestionOnYes;
  final List<Question> subQuestions;
  final List<ChoiceQuestion> choiceQuestions;

  const Question({
    required this.numberQuestion,
    required this.question,
    required this.questionHighlight,
    this.labelLeft = "",
    this.labelRight = "",
    this.isYesnoQuestion = false,
    this.useChoice = false,
    this.showSubQuestionOnYes = false,
    this.subQuestions = const [],
    this.choiceQuestions = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      numberQuestion: json['numberQuestion'] ?? "",
      question: json['question'] ?? "",
      questionHighlight:
          json['questionHighlight'] != null
              ? List<HightLightText>.from(
                json['questionHighlight'].map(
                  (x) => HightLightText(
                    text: x['text'] ?? "",
                    underline:
                        x['underline'] != null
                            ? List<String>.from(x['underline'])
                            : const [],
                  ),
                ),
              )
              : [],
      labelLeft: json['labelLeft'] ?? "",
      labelRight: json['labelRight'] ?? "",
      isYesnoQuestion: json['isYesnoQuestion'] ?? false,
      useChoice: json['useChoice'] ?? false,
      showSubQuestionOnYes: json['showSubQuestionOnYes'] ?? false,
      subQuestions:
          json['subQuestions'] != null
              ? List<Question>.from(
                json['subQuestions'].map((x) => Question.fromJson(x)),
              )
              : [],
      choiceQuestions:
          json['choiceQuestions'] != null
              ? List<ChoiceQuestion>.from(
                json['choiceQuestions'].map((x) => ChoiceQuestion.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numberQuestion': numberQuestion,
      'question': question,
      'questionHighlight':
          questionHighlight.isNotEmpty
              ? questionHighlight.map((x) => x.toJson()).toList()
              : [],
      'labelLeft': labelLeft,
      'labelRight': labelRight,
      'isYesnoQuestion': isYesnoQuestion,
      'useChoice': useChoice,
      'showSubQuestionOnYes': showSubQuestionOnYes,
      'subQuestions':
          subQuestions.isNotEmpty
              ? subQuestions.map((x) => x.toJson()).toList()
              : [],
      'choiceQuestions':
          choiceQuestions.isNotEmpty
              ? choiceQuestions.map((x) => x.toJson()).toList()
              : [],
    };
  }

  @override
  String toString() {
    return 'Question(numberQuestion: $numberQuestion, question: $question, questionHighlight: $questionHighlight, labelLeft: $labelLeft, labelRight: $labelRight, isYesnoQuestion: $isYesnoQuestion, useChoice: $useChoice, showSubQuestionOnYes: $showSubQuestionOnYes, subQuestions: $subQuestions)';
  }

  @override
  List<Object?> get props => [
    numberQuestion,
    question,
    questionHighlight,
    labelLeft,
    labelRight,
    isYesnoQuestion,
    useChoice,
    showSubQuestionOnYes,
    subQuestions,
    choiceQuestions,
  ];
}

class ChoiceQuestion extends Equatable {
  final String question;
  final String? imagePath;

  const ChoiceQuestion({required this.question, this.imagePath});

  factory ChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return ChoiceQuestion(
      question: json['question'] ?? "",
      imagePath: json['imagePath'] ?? "",
    );
  }

  //toJson
  Map<String, dynamic> toJson() {
    return {'question': question, 'image_path': imagePath};
  }

  @override
  String toString() {
    return 'ChoiceQuestion(question: $question, imagePath: $imagePath)';
  }

  @override
  List<Object?> get props => [question, imagePath];
}

class HightLightText extends Equatable {
  final String text;
  final List<String> underline;

  const HightLightText({required this.text, this.underline = const []});

  factory HightLightText.fromJson(Map<String, dynamic> json) {
    return HightLightText(
      text: json['text'] ?? "",
      underline:
          json['underline'] != null
              ? List<String>.from(json['underline'])
              : const [],
    );
  }

  //toJson
  Map<String, dynamic> toJson() {
    return {'text': text, 'underline': underline};
  }

  @override
  String toString() {
    return 'HightLightText(text: $text, underline: $underline)';
  }

  @override
  List<Object?> get props => [text, underline];
}
