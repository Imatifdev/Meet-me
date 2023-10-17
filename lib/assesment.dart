import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AssessmentScreen(),
    );
  }
}

class AssessmentScreen extends StatefulWidget {
  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int currentQuestionIndex = 0;
  List<String> answers = [];
  List<List<String>> questions = [
    ['Question 1', 'Answer 1', 'Answer 2'],
    ['Question 2', 'Answer 1', 'Answer 2'],
    ['Question 3', 'Answer 1', 'Answer 2', 'Answer 3', 'Answer 4'],
    ['Question 4', 'Answer 1', 'Answer 2'],
    ['Question 5', 'Answer 1', 'Answer 2'],
  ];

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      setState(() {});
    } else {
      // Handle assessment completion
    }
  }

  void selectAnswer(String answer) {
    answers.add(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
            ),
            SizedBox(height: 20),
            Text(
              questions[currentQuestionIndex][0],
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Column(
              children:
                  questions[currentQuestionIndex].sublist(1).map((answer) {
                return RadioListTile(
                  title: Text(answer),
                  value: answer,
                  groupValue: answers.length > currentQuestionIndex
                      ? answers[currentQuestionIndex]
                      : null,
                  onChanged: (selectedAnswer) {
                    setState(() {
                      selectAnswer(selectedAnswer!);
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: nextQuestion,
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
