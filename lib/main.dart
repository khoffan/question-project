import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:questionnaire/application.dart';
import 'package:questionnaire/cubit/answer_cubit.dart';
import 'package:questionnaire/model/question_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final questions = await loadQuestions();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  runApp(MyApp(questions: questions));
}

Future<List<Question>> loadQuestions() async {
  final jsonString = await rootBundle.loadString(
    'assets/question/questions.json',
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
      home: BlocProvider(
        create: (context) => AnswerCubit(),
        child: Application(questions: questions),
      ),
    );
  }
}
