import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:questionnaire/model/question_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FormDataSource {
  Future<List<Question>?> getQuestions();
  Future<Map<String, dynamic>?> saveFormAnswer(
    Map<String, dynamic> formAnswerModel,
  );

}

class FormDataSourceImpl implements FormDataSource {
  FormDataSourceImpl({Dio? dio, SharedPreferences? sharedPreferences})
    : _dio = dio ?? Dio(),
      _sharedPreferences = sharedPreferences!;

  final Dio _dio;
  final String baseApiUrl = "http://localhost:1112";


  @override
  Future<List<FormModel>?> getFormQuestions() async {
    try {
      await _dio.get("$baseApiUrl/questions");
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> saveFormAnswer(
    Map<String, dynamic> formAnswerModel,
  ) async {
    try {
      final key = answerKey(formAnswerModel.formId);
      await _sharedPreferences.setString(
        key,
        jsonEncode(formAnswerModel.toJson()),
      );
      final response = await _dio.post(
        "$baseApiUrl/form",
        data: formAnswerModel,

      );
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
