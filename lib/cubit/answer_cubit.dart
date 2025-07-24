import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questionnaire/datasource/form_datasource.dart';
import 'package:questionnaire/datasource/form_local_datasouce.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnswerCubit extends Cubit<List<AnswerModel>> {
  final FormLocalDataSource formLocalDataSource;
  final FormDataSource formDataSource;
  final SharedPreferences sharedPrefService;

  AnswerCubit({
    required this.formLocalDataSource,
    required this.formDataSource,
    required this.sharedPrefService,
  }) : super([]);

  void saveAllAnswerLocal({
    required String patientId,
    required List<AnswerModel> answers,
  }) async {
    // print(answers.length);
    await formLocalDataSource.saveAllAnswer(patientId, answers);
  }

  void clearAllAnswerLocal() async {
    await formLocalDataSource.deleteAllAnswer();
    // emit([]);
  }

  void saveAnswer({
    required String questionId,
    required String value,
    Map<String, List<TapPointEntity>>? tapPoints,
    String? parentId,
  }) {
    final updateList = _updateOrinsertV2(
      state,
      questionId,
      value,
      tapPoints,
      parentId,
    );
    emit(updateList);
  }

  Map<String, dynamic>? _cachedAnswers;
  Future<Map<String, dynamic>>? _cachedFuture;

  Future<Map<String, dynamic>> getAll() {
    if (_cachedFuture != null) return _cachedFuture!;
    _cachedFuture = _getAllAnswers();
    return _cachedFuture!;
  }

  Future<Map<String, dynamic>> _getAllAnswers() async {
    final answers = await formLocalDataSource.getAllAnswers();
    _cachedAnswers = answers;
    return answers;
  }

  Map<String, dynamic>? get answers => _cachedAnswers;

  List<AnswerModel> _updateOrinsertV2(
    List<AnswerModel> list,
    String questionId,
    String value,
    Map<String, List<TapPointEntity>>? tapPoints,
    String? parentId,
  ) {
    bool updated = false;
    List<AnswerModel> updatedList = [];

    for (final answer in list) {
      if (parentId != null && answer.numberQuestion == parentId) {
        // กรณี subAnswer
        final updatedSubAnswers = _updateOrinsertV2(
          answer.subAnswers,
          questionId,
          value,
          null,
          null,
        );
        updatedList.add(answer.copyWith(subAnswers: updatedSubAnswers));
        updated = true;
      } else if (parentId == null && answer.numberQuestion == questionId) {
        // คำตอบหลัก
        updatedList.add(answer.copyWith(answer: value, tapPoints: tapPoints));
        updated = true;
      } else {
        updatedList.add(answer);
      }
    }

    if (!updated) {
      if (parentId == null) {
        // เป็นคำตอบหลัก
        updatedList.add(
          AnswerModel(
            numberQuestion: questionId,
            answer: value,
            tapPoints: tapPoints,
            subAnswers: [],
          ),
        );
      } else {
        // เป็น subAnswer — หา parent แล้วเพิ่มเข้าไป
        updatedList.add(
          AnswerModel(
            numberQuestion: parentId,
            answer: '',
            subAnswers: [
              AnswerModel(
                numberQuestion: questionId,
                answer: value,
                subAnswers: [],
              ),
            ],
          ),
        );
      }
    }

    return updatedList;
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

  Future<void> restoreAnswersFromLocal() async {
    final answersMap =
        await formLocalDataSource.getAllAnswers(); // Map<String, dynamic>

    final List<String> sortedQuestionIds =
        answersMap.keys.toList()..sort(); // จัดเรียงตามลำดับคำถาม

    String? currentParentId;

    for (final questionId in sortedQuestionIds) {
      final answer = answersMap[questionId].toString();
      String? parentId;

      // ถ้า questionId มีรูปแบบ 20a, 10b, etc.
      final match = RegExp(r'^\d+[a-zA-Z]$').firstMatch(questionId);

      if (match != null && (answer == 'yes' || answer == 'no')) {
        currentParentId = questionId; // ใช้ question นี้เป็น parent ถัดไป
      }

      // ถ้าไม่ใช่ตัวแรกที่จบด้วย yes/no เราก็ผูก parentId
      parentId = currentParentId;

      // print('questionId: $questionId, answer: $answer, parentId: $parentId');

      saveAnswer(questionId: questionId, value: answer, parentId: parentId);
    }
  }

  void saveLocal(String questionId, dynamic answer) async {
    await formLocalDataSource.saveAnswerLocal(questionId, answer);
  }

  void saveFormAnswer(Map<String, dynamic> data) async {
    await formDataSource.saveFormAnswer(data);
  }
}
