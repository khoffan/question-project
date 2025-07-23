import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:questionnaire/model/question_model.dart';

abstract class FormDataSource {
  Future<List<Question>?> getQuestions();
  Future<FormAnswerModel?> saveFormAnswer(FormAnswerModel formAnswerModel);
}

class FormDataSourceImpl implements FormDataSource {
  FormDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final String baseApiUrl = "http://localhost:3000/api";

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
  Future<FormAnswerModel?> saveFormAnswer(
    FormAnswerModel formAnswerModel,
  ) async {
    try {
      final response = await _dio.post(
        "$baseApiUrl/form",
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
