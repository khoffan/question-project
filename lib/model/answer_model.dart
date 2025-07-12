import 'package:equatable/equatable.dart';

class AnswerModel extends Equatable {
  final String questionId;
  final String answer;

  const AnswerModel({required this.questionId, required this.answer});

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(questionId: json['questionId'], answer: json['answer']);
  }

  Map<String, dynamic> toJson() {
    return {'questionId': questionId, 'answer': answer};
  }

  @override
  String toString() {
    return 'AnswerModel(questionId: $questionId, answer: $answer)';
  }

  @override
  List<Object?> get props => [questionId, answer];
}
