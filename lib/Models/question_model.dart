class Question {
  final String description;
  final List<Option> options;
  final String detailedSolution; // Added field for detailed explanation

  Question({
    required this.description,
    required this.options,
    required this.detailedSolution,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var optionsList = (json['options'] as List)
        .map((option) => Option.fromJson(option))
        .toList();
    return Question(
      description: json['description'],
      options: optionsList,
      detailedSolution: json['detailed_solution'] ?? '',
    );
  }
}

class Option {
  final String description;
  final bool isCorrect;

  Option({required this.description, required this.isCorrect});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      description: json['description'],
      isCorrect: json['is_correct'],
    );
  }
}
