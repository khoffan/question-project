import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FormLocalDataSource {
  Future<void> saveAnswerLocal(String questionId, dynamic answers);
  Future<void> saveAllAnswer(String patientId, List<AnswerModel> formAnswer);
  Future<List<AnswerModel>> getAllAnswer(String patientId);
  Future<dynamic> getAnswer(String questionId);
  Future<void> deleteAllAnswer();
}

class FormLocalDataSourceImpl implements FormLocalDataSource {
  final SharedPreferences _sharedPrefService;

  FormLocalDataSourceImpl({required SharedPreferences sharedPreferences})
    : _sharedPrefService = sharedPreferences;

  @override
  Future<void> saveAnswerLocal(String questionId, dynamic answers) async {
    try {
      if (answers is Map<String, List<TapPointEntity>>) {
        final endcode = jsonEncode(
          answers.map(
            (key, value) => MapEntry(key, value.map((e) => e.toMap()).toList()),
          ),
        );

        await _sharedPrefService.setString("answer_$questionId", endcode);
      } else {
        final endcode = jsonEncode(answers);

        await _sharedPrefService.setString("answer_$questionId", endcode);
      }
    } catch (e) {
      debugPrint("save answer local error: $e");
    }
  }

  @override
  Future<void> saveAllAnswer(
    String patientId,
    List<AnswerModel> formAnswer,
  ) async {
    try {
      final endcode = jsonEncode(formAnswer.map((e) => e.toJson()).toList());

      await _sharedPrefService.setString("answers_$patientId", endcode);
    } catch (e) {
      debugPrint("save answer local error: $e");
    }
  }

  @override
  Future<dynamic> getAnswer(String questionId) async {
    try {
      final answers = _sharedPrefService.getString("answer_$questionId");
      print("answer = $answers");
      if (answers != null) {
        final decoded = jsonDecode(answers);
        return decoded;
      }
      return null;
    } catch (e) {
      debugPrint("get answer local error: $e");
      return null;
    }
  }

  @override
  Future<List<AnswerModel>> getAllAnswer(String patientId) async {
    try {
      final answers = _sharedPrefService.getString("answers_$patientId");
      if (answers != null) {
        final decoded = jsonDecode(answers);
        return decoded.map((e) => AnswerModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("get answer local error: $e");
      return [];
    }
  }

  @override
  Future<void> deleteAllAnswer() async {
    try {
      final keys = _sharedPrefService.getKeys();

      for (final key in keys) {
        if (!key.startsWith("answer_")) {
          await _sharedPrefService.remove(key);
        }
      }
    } catch (e) {
      debugPrint("delete non-answer keys error: $e");
    }
  }
}
