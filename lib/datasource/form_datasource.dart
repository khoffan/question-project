import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:questionnaire/model/question_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FormDataSource {
  Future<List<FormModel>?> getFormQuestions();
  Future<FormAnswerModel?> saveFormAnswer(FormAnswerModel formAnswerModel);
}

class FormDataSourceImpl implements FormDataSource {
  FormDataSourceImpl({Dio? dio, SharedPreferences? sharedPreferences})
    : _dio = dio ?? Dio(),
      _sharedPreferences = sharedPreferences!;

  final Dio _dio;
  final SharedPreferences _sharedPreferences;
  final String baseApiUrl = "http://localhost:3000/api";
  String answerKey(String formid) {
    return "answer_key_$formid";
  }

  @override
  Future<List<FormModel>?> getFormQuestions() async {
    try {
      final response = await _dio.get("$baseApiUrl/forms");
      if (response.statusCode == 200) {
        print("data: ${response.data}");
        final data = response.data;
        return (data as List).map((x) => FormModel.fromJson(x)).toList();
      }
      return [];
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<FormAnswerModel?> saveFormAnswer(
    FormAnswerModel formAnswerModel,
  ) async {
    try {
      final key = answerKey(formAnswerModel.formId);
      await _sharedPreferences.setString(
        key,
        jsonEncode(formAnswerModel.toJson()),
      );
      final response = await _dio.post(
        "$baseApiUrl/answer",
        data: formAnswerModel.toJson(),
      );
      if (response.statusCode == 200) {
        return FormAnswerModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
