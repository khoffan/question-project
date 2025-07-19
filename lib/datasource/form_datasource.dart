import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:questionnaire/model/answer_model.dart';
import 'package:questionnaire/model/question_model.dart';

abstract class FormDataSource {
  Future<List<FormModel>?> getFormQuestions();
  Future<FormAnswerModel?> saveFormAnswer(FormAnswerModel formAnswerModel);
}

class FormDataSourceImpl implements FormDataSource {
  FormDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final String baseApiUrl = "http://localhost:3000/api";

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
