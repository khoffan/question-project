import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:questionnaire_project/application.dart';
import 'package:questionnaire_project/model/question_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final questions = await loadQuestions();
  runApp(MyApp(questions: questions));
}

Future<List<Question>> loadQuestions() async {
  final jsonString = await rootBundle.loadString(
    'assets/question/question.json',
  );
  final jsonMap = json.decode(jsonString);
  if (jsonMap is List) {
    final questionList = jsonMap.map((e) => Question.fromJson(e)).toList();
    return questionList;
  } else {
    throw Exception('Invalid JSON format');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.questions});
  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAINPREDICT',
      debugShowCheckedModeBanner: false,
      home: Application(questions: questions),
    );
  }
}
