import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questionnaire_project/cubit/answer_state.dart';
import 'package:questionnaire_project/model/answer_model.dart';

class AnswerCubit extends Cubit<AnswerState> {
  AnswerCubit() : super(const AnswerState(answers: {}));

  void saveAnswer(String questionId, String answer) {
    final newAnswers = AnswerModel(questionId: questionId, answer: answer);
    final updateAnswer = {...state.answers, questionId: newAnswers};

    emit(state.copyWith(answers: updateAnswer));
  }
}
