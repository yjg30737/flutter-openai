import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Replace YOUR_API_KEY with your actual API key
const apiKey = "[YOUR_API_KEY]";
String apiUrl = "https://api.openai.com/v1/completions";
Uri uri = Uri.parse(apiUrl);

Future<String> generateText(String prompt) async {
  final response = await http.post(
    uri,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    },
    body: jsonEncode({
      "model": "text-davinci-003",
      "prompt": prompt,
      "max_tokens": 100,
      "temperature": 0.5
    }),
  );

  print(response.body);

  if (response.statusCode == 200) {
    final responseJson = jsonDecode(response.body);
    return responseJson['choices'][0]['text'].trim();
  } else {
    throw Exception("Failed to generate text");
  }
}

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatting App',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _messages = <String>[];

  void _sendMessage() async {
    String message = _textController.text;
    setState(() {
      _messages.add(message);
      _textController.clear();
    });

    String response = await _getResponse(message);
    setState(() {
      _messages.add(response);
    });
  }

  Future<String> _getResponse(String message) async {
    return await generateText(message);
  }

  Widget _buildMessage(String message, bool isUser) {
    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue[200] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatting App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
                children: _messages.map((message) => _buildMessage(message, false)).toList()
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _sendMessage,
                  child: Text('SEND'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
