import 'dart:convert';
import 'dart:ui';
import 'package:equatable/equatable.dart';

class AnswerModel extends Equatable {
  final String numberQuestion;
  final String answer;
  final Map<String, List<TapPointEntity>>? tapPoints;
  final List<AnswerModel> subAnswers;

  const AnswerModel({
    required this.numberQuestion,
    required this.answer,
    this.tapPoints,
    required this.subAnswers,
  });

  AnswerModel copyWith({
    String? answer,
    List<AnswerModel>? subAnswers,
    Map<String, List<TapPointEntity>>? tapPoints,
  }) {
    return AnswerModel(
      numberQuestion: numberQuestion,
      answer: answer ?? this.answer,
      tapPoints: tapPoints ?? this.tapPoints,
      subAnswers: subAnswers ?? this.subAnswers,
    );
  }

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      numberQuestion: json['number_question'] ?? "",
      answer: json['answer'] ?? "",
      tapPoints:
          json['tap_points'] != null
              ? (json['tap_points'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(
                  key,
                  (value as List<dynamic>)
                      .map((e) => TapPointEntity.fromMap(e))
                      .toList(),
                ),
              )
              : null,
      subAnswers:
          json['sub_answers'] != null
              ? List<AnswerModel>.from(json['sub_answers'])
              : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number_question': numberQuestion,
      'answer':
          tapPoints != null
              ? tapPoints!.map(
                (key, value) =>
                    MapEntry(key, value.map((e) => e.toMap()).toList()),
              )
              : answer,
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
    return 'AnswerModel(number_question: $numberQuestion, answer: $answer, tapPoints: $tapPoints, subAnswers: $subAnswers)';
  }

  @override
  List<Object?> get props => [numberQuestion, answer, tapPoints, subAnswers];
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

class TapPointEntity {
  final double x;
  final double y;

  TapPointEntity({required this.x, required this.y});

  factory TapPointEntity.fromOffset(Offset offset) {
    return TapPointEntity(x: offset.dx, y: offset.dy);
  }

  Offset toOffset() => Offset(x, y);

  Map<String, dynamic> toMap() => {
    'x': x.toStringAsFixed(3),
    'y': y.toStringAsFixed(3),
  };

  factory TapPointEntity.fromMap(Map<String, dynamic> map) =>
      TapPointEntity(x: double.parse(map['x']), y: double.parse(map['y']));

  @override
  toString() {
    return 'TapPointEntity(x: $x, y: $y)';
  }
}
