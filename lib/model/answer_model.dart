import 'dart:convert';
import 'package:equatable/equatable.dart';

class AnswerModel extends Equatable {
  final String numberQuestion;
  final String answer;
  final List<AnswerModel> subAnswers;

  const AnswerModel({
    required this.numberQuestion,
    required this.answer,
    required this.subAnswers,
  });

  AnswerModel copyWith({String? answer, List<AnswerModel>? subAnswers}) {
    return AnswerModel(
      numberQuestion: numberQuestion,
      answer: answer ?? this.answer,
      subAnswers: subAnswers ?? this.subAnswers,
    );
  }

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      numberQuestion: json['number_question'] ?? "",
      answer: json['answer'] ?? "",
      subAnswers:
          json['sub_answers'] != null
              ? List<AnswerModel>.from(json['sub_answers'])
              : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number_question': numberQuestion,
      'answer': jsonDecodeIfNeeded(answer),
      if (subAnswers.isNotEmpty)
        'sub_answers': subAnswers.map((e) => e.toJson()).toList(),
    };
  }

  dynamic jsonDecodeIfNeeded(String value) {
    try {
      return json.decode(value);
    } catch (_) {
      return value;
    }
  }

  @override
  String toString() {
    return 'AnswerModel(number_question: $numberQuestion, answer: $answer, subAnswers: $subAnswers)';
  }

  @override
  List<Object?> get props => [numberQuestion, answer, subAnswers];
}

class FormAnswerModel extends Equatable {
  final String formId;
  final String userid;
  final String patientId;
  final String patienName;
  final List<AnswerModel> answers;

  const FormAnswerModel({
    required this.formId,
    required this.userid,
    required this.patientId,
    required this.patienName,
    required this.answers,
  });

  FormAnswerModel copyWith({
    String? formId,
    String? userid,
    String? patientId,
    String? patienName,
    List<AnswerModel>? answers,
  }) {
    return FormAnswerModel(
      formId: formId ?? this.formId,
      userid: userid ?? this.userid,
      patientId: patientId ?? this.patientId,
      patienName: patienName ?? this.patienName,
      answers: answers ?? this.answers,
    );
  }

  factory FormAnswerModel.fromJson(Map<String, dynamic> json) {
    return FormAnswerModel(
      formId: json['form_id'] ?? "",
      userid: json['user_id'] ?? "",
      patientId: json['patient_id'] ?? "",
      patienName: json['patient_name'] ?? "",
      answers:
          json['answers'] != null
              ? List<AnswerModel>.from(json['answers'])
              : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'form_id': formId,
      'user_id': userid,
      'patient_id': patientId,
      'patient_name': patienName,
      'answers': answers.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [formId, userid, patientId, patienName, answers];
}
