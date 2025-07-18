import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questionnaire/model/answer_model.dart';

class AnswerCubit extends Cubit<List<AnswerModel>> {
  AnswerCubit() : super([]);

  void saveAnswer({
    required String questionId,
    required String value,
    String? parentId,
  }) {
    final updateList = _updateOrinsert(state, questionId, value, parentId);
    emit(updateList);
  }

  List<AnswerModel> _updateOrinsert(
    List<AnswerModel> list,
    String questionId,
    String value,
    String? parentId,
  ) {
    bool updated = false;
    List<AnswerModel> updatedList = [];

    for (final answer in list) {
      if (answer.numberQuestion == questionId && parentId == null) {
        updatedList.add(answer.copyWith(answer: value));
        updated = true;
      } else if (answer.numberQuestion == parentId) {
        updatedList.add(
          answer.copyWith(
            subAnswers: _updateOrinsert(
              answer.subAnswers,
              questionId,
              value,
              null,
            ),
          ),
        );
        updated = true;
      } else {
        updatedList.add(answer);
      }
    }

    if (!updated && parentId == null) {
      updatedList.add(
        AnswerModel(numberQuestion: questionId, answer: value, subAnswers: []),
      );
    }

    return updatedList;
  }
}
