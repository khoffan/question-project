import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:questionnaire/application.dart';
import 'package:questionnaire/cubit/answer_cubit.dart';
import 'package:questionnaire/datasource/form_datasource.dart';
import 'package:questionnaire/datasource/form_local_datasouce.dart';
import 'package:questionnaire/model/question_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:questionnaire/singleton/shared_pref_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final questions = await loadQuestions();
  if (kIsWeb) {
    usePathUrlStrategy();
    await SharedPrefsService.init();
  }

  runApp(
    EasyLocalization(
      supportedLocales: FolderBasedAssetLoader.supportedLocales,
      path: 'assets/translations',
      assetLoader: FolderBasedAssetLoader(files: ['questionire']),
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: MyApp(questions: questions),
    ),
  );
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
    context.locale;
    return MaterialApp(
      title: 'PAINPREDICT',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: BlocProvider(
        create:
            (context) => AnswerCubit(
              formLocalDataSource: FormLocalDataSourceImpl(
                sharedPreferences: SharedPrefsService.instance,
              ),
              formDataSource: FormDataSourceImpl(),
              sharedPrefService: SharedPrefsService.instance,
            ),
        child: Application(questions: questions),
      ),
    );
  }
}

class FolderBasedAssetLoader extends AssetLoader {
  final List<String> files;

  FolderBasedAssetLoader({required this.files});

  static const List<Locale> supportedLocales = [Locale('en'), Locale('th')];

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final Map<String, dynamic> result = {};

    for (final file in files) {
      final fullPath = '$path/${locale.languageCode}/$file.json';
      final data = await rootBundle.loadString(fullPath);
      final map = json.decode(data) as Map<String, dynamic>;
      result.addAll(map);
    }

    return result;
  }
}
