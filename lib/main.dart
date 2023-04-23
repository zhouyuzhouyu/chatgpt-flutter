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
        textTheme: TextTheme(
          bodyText2: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 18.0,
            color: Colors.black,
          ),
        ),
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
  final List<OpenAIChatCompletionChoiceMessageModel> _history = [];
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGPT/gpt3.5-turbo'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _history.clear();
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: false,
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final message = _history[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: message.role == OpenAIChatMessageRole.user
                                ? Colors.blue.shade50
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 1,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(
                                message.role == OpenAIChatMessageRole.user
                                    ? Icons.person
                                    : Icons.android,
                              ),
                              onPressed: () {
                                setState(() {
                                  _history.removeAt(index);
                                });
                              },
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: SelectableText(
                                message.content,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _history.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(16.0),
                        elevation: 5.0,
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 28.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final prompt = _controller.text;
    if (prompt.isNotEmpty) {
      _controller.clear();
      _history.add(
        OpenAIChatCompletionChoiceMessageModel(
          content: prompt,
          role: OpenAIChatMessageRole.user,
        ),
      );

      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 在页面更新完成后执行要执行的代码
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      });

      chatGPT(_history).then((response) {
        _history.add(
          OpenAIChatCompletionChoiceMessageModel(
            content: response,
            role: OpenAIChatMessageRole.assistant,
          ),
        );
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 在页面更新完成后执行要执行的代码
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut);
        });
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('$error'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  Future<String> chatGPT(
    List<OpenAIChatCompletionChoiceMessageModel> history,
  ) async {
    OpenAI.apiKey = Env.apiKey;
    try {
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: history,
        temperature: 0.7,
        maxTokens: 2048,
      );
      return chatCompletion.choices.first.message.content;
    } on RequestFailedException catch (e) {
      return Future.error(e.message);
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}
