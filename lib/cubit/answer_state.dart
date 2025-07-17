import 'package:equatable/equatable.dart';
import 'package:questionnaire_project/model/answer_model.dart';

class AnswerState extends Equatable {
  final Map<String, AnswerModel> answers;
  const AnswerState({required this.answers});

  AnswerState copyWith({Map<String, AnswerModel>? answers}) {
    return AnswerState(answers: answers ?? this.answers);
  }

  @override
  List<Object?> get props => [answers];
}
