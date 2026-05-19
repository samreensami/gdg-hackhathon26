import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    home: InsightFlowChatScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class InsightFlowChatScreen extends StatefulWidget {
  final String province;
  final String language;

  const InsightFlowChatScreen({
    Key? key, 
    this.province = 'all', 
    this.language = 'en'
  }) : super(key: key);

  @override
  _InsightFlowChatScreenState createState() => _InsightFlowChatScreenState();
}

class _InsightFlowChatScreenState extends State<InsightFlowChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Connected directly to your live production Cloud Run backend URL
  final String _backendUrl = "https://insightflow-ai-839657721881.asia-south1.run.app/chat"; 

  Future<void> _sendMessage() async {
    final userText = _messageController.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.insert(0, {"sender": "user", "text": userText});
      _isLoading = true;
    });
    _messageController.clear();

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": userText,
          "province": widget.province,
          "language": widget.language,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botReply = data['reply'] ?? data['text'] ?? "No analysis returned.";
        
        setState(() {
          _messages.insert(0, {"sender": "bot", "text": botReply});
        });
      } else {
        throw Exception("Server Error");
      }
    } catch (e) {
      setState(() {
        _messages.insert(0, {
          "sender": "bot", 
          "text": "⚠️ **Sync Timeout:** Cloud Agent response model layer structure is updating. Verify active container logs on Cloud Run."
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("InsightFlow AI Risk Consultant"),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: Container(
        color: const Color(0xFF020617),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg["sender"] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF0EA5E9) : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: isUser 
                        ? Text(msg["text"]!, style: const TextStyle(color: Colors.white, fontSize: 15))
                        : MarkdownBody(
                            data: msg["text"]!,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: Colors.white, fontSize: 14),
                              strong: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                            ),
                          ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9))),
              ),
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Ask anything about Pakistan business risks...",
                        hintStyle: TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF0EA5E9)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}