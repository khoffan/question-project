import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:questionnaire/model/question_model.dart';

abstract class FormDataSource {
  Future<List<Question>?> getQuestions();
  Future<Map<String, dynamic>?> saveFormAnswer(
    Map<String, dynamic> formAnswerModel,
  );
}

class FormDataSourceImpl implements FormDataSource {
  FormDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final String baseApiUrl = "http://localhost:1112";

  @override
  Future<List<Question>?> getQuestions() async {
    try {
      await _dio.get("$baseApiUrl/questions");
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> saveFormAnswer(
    Map<String, dynamic> formAnswerModel,
  ) async {
    try {
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
