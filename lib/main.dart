import 'package:chatgpt/env/env.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/openai.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGPT'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length * 2,
              itemBuilder: (context, index) {
                if (index.isEven) {
                  final message = _messages[index ~/ 2];
                  return Container(
                    padding: EdgeInsets.all(8),
                    child: SelectableText(
                      message,
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                } else {
                  return Divider(
                    color: Colors.grey,
                    thickness: 1,
                  );
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final prompt = _controller.text;
    if (prompt.isNotEmpty) {
      _controller.clear();
      _messages.add('USER: $prompt');
      setState(() {});
      chatGPT(prompt).then((response) {
        _messages.add('ASSISTANT: $response');
        setState(() {});
      });
    }
  }

  Future<String> chatGPT(String prompt) async {
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
    return chatCompletion.choices.first.message.content;
  }
}

// Future<String> chatGPT(String prompt) async {
//   OpenAI.apiKey = Env.apiKey;
//   OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
//     model: "gpt-3.5-turbo",
//     messages: [
//       OpenAIChatCompletionChoiceMessageModel(
//         content: prompt,
//         role: OpenAIChatMessageRole.user,
//       ),
//     ],
//   );
//   return chatCompletion.choices.first.message.content;
// }
