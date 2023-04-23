import 'package:chatgpt/env/env.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'package:dart_openai/openai.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final textController = TextEditingController();
  String responseText = '';

  Future<String> generateText(String prompt) async {
    OpenAI.apiKey = Env.apiKey;
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: prompt,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );
    // print(chatCompletion.toMap());
    return chatCompletion.choices.first.message.content;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenAI Chat',
      home: Scaffold(
        appBar: AppBar(
          title: Text('OpenAI Chat'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'AI: ' + responseText,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'You:',
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String prompt = textController.text;
                    String response = await generateText(prompt);
                    setState(() {
                      responseText = response;
                    });
                    textController.clear();
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
