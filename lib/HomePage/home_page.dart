import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz_app/Apis/api_function.dart';
import 'package:quiz_app/Components/completion_dialog.dart';
import 'package:quiz_app/Models/question_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.Name});

  final String? Name;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Question>> futureQuestions;
  Map<int, String> selectedAnswers = {};
  Map<int, bool> submittedQuestions =
      {}; // Track which questions have been submitted
  int score = 0;
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    futureQuestions = fetchQuestions();
  }

  void handleAnswerSelection(String selectedAnswer) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = selectedAnswer;
    });
  }

  void handleSubmit(Question question) {
    final correctOption =
        question.options.firstWhere((option) => option.isCorrect);

    setState(() {
      submittedQuestions[currentQuestionIndex] = true;
      if (selectedAnswers[currentQuestionIndex] == correctOption.description) {
        score += 1;
      }
    });
  }

  Widget buildQuestionCard(Question question) {
    final isSubmitted = submittedQuestions[currentQuestionIndex] ?? false;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              question.description,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ...question.options.map((option) {
              final isSelected =
                  selectedAnswers[currentQuestionIndex] == option.description;
              final isCorrect = option.isCorrect;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSubmitted
                        ? (isCorrect
                            ? Colors.green
                            : (isSelected ? Colors.red : Colors.grey[300]!))
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                  color: isSubmitted
                      ? (isCorrect
                          ? Colors.green.withOpacity(0.1)
                          : (isSelected
                              ? Colors.red.withOpacity(0.1)
                              : Colors.white))
                      : (isSelected
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.white),
                ),
                child: RadioListTile(
                  title: Text(
                    option.description,
                    style: GoogleFonts.poppins(
                      color: isSubmitted
                          ? (isCorrect
                              ? Colors.green[700]
                              : (isSelected ? Colors.red[700] : Colors.black87))
                          : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  value: option.description,
                  groupValue: selectedAnswers[currentQuestionIndex],
                  onChanged: isSubmitted
                      ? null
                      : (value) => handleAnswerSelection(value.toString()),
                  activeColor: Colors.blue[700],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            if (!isSubmitted)
              Center(
                child: ElevatedButton(
                  onPressed: selectedAnswers[currentQuestionIndex] == null
                      ? null
                      : () => handleSubmit(question),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Submit Answer',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quiz App',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Score: $score',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Question>>(
                future: futureQuestions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final questions = snapshot.data!;
                    final question = questions[currentQuestionIndex];
                    final isSubmitted =
                        submittedQuestions[currentQuestionIndex] ?? false;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          buildQuestionCard(question),
                          if (isSubmitted)
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.blue[100]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detailed Solution',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  MarkdownBody(
                                    data: question.detailedSolution,
                                    styleSheet: MarkdownStyleSheet(
                                      p: GoogleFonts.poppins(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (currentQuestionIndex > 0)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        currentQuestionIndex--;
                                      });
                                    },
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text('Previous'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      foregroundColor: Colors.black87,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                if (isSubmitted)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (currentQuestionIndex <
                                          questions.length - 1) {
                                        setState(() {
                                          currentQuestionIndex++;
                                        });
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (_) => CompletionDialog(
                                            Name: widget.Name,
                                            Score: score,
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(currentQuestionIndex <
                                            questions.length - 1
                                        ? Icons.arrow_forward
                                        : Icons.check),
                                    label: Text(
                                      currentQuestionIndex <
                                              questions.length - 1
                                          ? 'Next'
                                          : 'Finish',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('No questions available'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
