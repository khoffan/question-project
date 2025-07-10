class Question {
  final String numberQuestion;
  final String question;
  final String questionHighlight;
  final String labelLeft;
  final String labelRight;
  final bool isYesnoQuestion;
  final bool useChoice;
  final bool showSubQuestionOnYes;
  final List<Question> subQuestions;

  Question({
    required this.numberQuestion,
    required this.question,
    required this.questionHighlight,
    this.labelLeft = "",
    this.labelRight = "",
    this.isYesnoQuestion = false,
    this.useChoice = false,
    this.showSubQuestionOnYes = false,
    this.subQuestions = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      numberQuestion: json['numberQuestion'] ?? "",
      question: json['question'] ?? "",
      questionHighlight: json['questionHighlight'] ?? "",
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
    );
  }

  @override
  String toString() {
    return 'Question(numberQuestion: $numberQuestion, question: $question, questionHighlight: $questionHighlight, labelLeft: $labelLeft, labelRight: $labelRight, isYesnoQuestion: $isYesnoQuestion, useChoice: $useChoice, showSubQuestionOnYes: $showSubQuestionOnYes, subQuestions: $subQuestions)';
  }
}
