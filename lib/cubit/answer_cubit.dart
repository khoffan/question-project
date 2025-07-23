import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questionnaire/datasource/form_local_datasouce.dart';
import 'package:questionnaire/model/answer_model.dart';

class AnswerCubit extends Cubit<List<AnswerModel>> {
  final FormLocalDataSource formLocalDataSource;

  AnswerCubit({required this.formLocalDataSource}) : super([]);

  void saveAllAnswerLocal({
    required String patientId,
    required List<AnswerModel> answers,
  }) async {
    await formLocalDataSource.saveAllAnswer(patientId, answers);
  }

  void clearAllAnswerLocal() async {
    await formLocalDataSource.deleteAllAnswer();
    emit([]);
  }

  void saveAnswer({
    required String questionId,
    required String value,
    Map<String, List<TapPointEntity>>? tapPoints,
    String? parentId,
  }) {
    final updateList = _updateOrinsert(
      state,
      questionId,
      value,
      tapPoints,
      parentId,
    );

    emit(updateList);
  }

  Future<dynamic> getAnswerLocal(String questionId) async {
    final answer = await formLocalDataSource.getAnswer(questionId);
    return answer;
  }

  List<AnswerModel> _updateOrinsert(
    List<AnswerModel> list,
    String questionId,
    String value,
    Map<String, List<TapPointEntity>>? tapPoints,
    String? parentId,
  ) {
    bool updated = false;
    List<AnswerModel> updatedList = [];

    for (final answer in list) {
      if (answer.numberQuestion == questionId && parentId == null) {
        updatedList.add(answer.copyWith(answer: value, tapPoints: tapPoints));
        updated = true;
      } else if (answer.numberQuestion == parentId) {
        updatedList.add(
          answer.copyWith(
            subAnswers: _updateOrinsert(
              answer.subAnswers,
              questionId,
              value,
              null,
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
        AnswerModel(
          numberQuestion: questionId,
          answer: value,
          tapPoints: tapPoints,
          subAnswers: [],
        ),
      );
    }

    return updatedList;
  }

  void saveLocal(String questionId, dynamic answer) async {
    await formLocalDataSource.saveAnswerLocal(questionId, answer);
  }
}
