import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FormLocalDataSource {
  Future<void> saveAnswerLocal(String questionId, dynamic answers);
  Future<void> saveAllAnswer(String patientId, List<AnswerModel> formAnswer);
  Future<List<AnswerModel>> getAllAnswer(String patientId);
  Future<Map<String, dynamic>> getAllAnswers();
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
      // print(endcode);

      await _sharedPrefService.setString("answers_$patientId", endcode);
    } catch (e) {
      debugPrint("save answer local error: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> getAllAnswers() async {
    try {
      final keys = _sharedPrefService.getKeys(); // ได้ List<String>
      final Map<String, dynamic> allAnswers = {};

      for (final key in keys) {
        if (key.startsWith("answer_")) {
          final questionId = key.replaceFirst("answer_", "");
          final raw = _sharedPrefService.getString(key);
          if (raw != null) {
            try {
              final decoded = jsonDecode(raw);
              allAnswers[questionId] = decoded;
            } catch (e) {
              debugPrint("decode error at $key: $e");
            }
          }
        }
      }

      return allAnswers;
    } catch (e) {
      debugPrint("get all answer local error: $e");
      return {};
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
        if (!key.startsWith("answers")) {
          await _sharedPrefService.remove(key);
        }
      }
    } catch (e) {
      debugPrint("delete non-answer keys error: $e");
    }
  }
}
