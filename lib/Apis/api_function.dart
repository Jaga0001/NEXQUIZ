import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app/Models/question_model.dart';

Future<List<Question>> fetchQuestions() async {
  final response =
      await http.get(Uri.parse('https://api.jsonserve.com/Uw5CrX'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['questions'] as List)
        .map((question) => Question.fromJson(question))
        .toList();
  } else {
    throw Exception('Failed to load quiz data');
  }
}
