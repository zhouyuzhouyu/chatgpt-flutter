import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer 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', // 将 YOUR_API_KEY 替换为你的 API 密钥
      },
      body: jsonEncode(<String, dynamic>{
        'model': 'gpt-3.5-turbo',
        'message': [
          {'role': 'user', 'content': prompt}
        ]
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var choices = jsonResponse['choices'][0];
      return choices['text'].toString();
    } else {
      return 'Error';
    }
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
