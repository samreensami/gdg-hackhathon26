import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, String>> messages = [
    {
      'role': 'bot',
      'text': 'Assalam o Alaikum! Main InsightFlow AI Assistant hoon. Pakistan ke business problems ke baare mein poochein! 🇵🇰'
    }
  ];
  
  bool isLoading = false;
  List<Map<String, String>> chatHistory = [];
  
  final List<String> quickQuestions = [
    'Supply chain crisis?',
    'Flood warning kya hai?',
    'Load shedding impact?',
    'PKR rate kya hai?',
  ];
  
  Future<void> sendMessage(String text) async {
    if(text.trim().isEmpty) return;
    
    _controller.clear();
    
    setState(() {
      messages.add({'role': 'user', 'text': text});
      isLoading = true;
    });
    
    scrollToBottom();
    
    try {
      final response = await http.post(
        Uri.parse('https://insightflow-ai-839657721881.asia-south1.run.app/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'history': chatHistory,
        }),
      ).timeout(const Duration(seconds: 15));
      
      final data = jsonDecode(response.body);
      final reply = data['reply'] ?? 'Maafi chahta hoon, kuch masla ho gaya.';
      
      chatHistory.add({'role': 'user', 'content': text});
      chatHistory.add({'role': 'assistant', 'content': reply});
      
      setState(() {
        messages.add({'role': 'bot', 'text': reply});
        isLoading = false;
      });
      
    } catch(e) {
      setState(() {
        messages.add({
          'role': 'bot',
          'text': 'Connection error. Please try again!'
        });
        isLoading = false;
      });
    }
    
    scrollToBottom();
  }
  
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if(_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text("⚡", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AI Assistant",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
                Text("Powered by Gemini AI",
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 11,
                  )),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if(i == messages.length) {
                  return _typingIndicator();
                }
                final msg = messages[i];
                final isBot = msg['role'] == 'bot';
                return _messageBubble(msg['text'] ?? '', isBot);
              },
            ),
          ),
          
          // Quick questions
          if(messages.length <= 2)
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: quickQuestions.map((q) =>
                  GestureDetector(
                    onTap: () => sendMessage(q),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                      ),
                      child: Text(q,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF3B82F6),
                          fontSize: 12,
                        )),
                    ),
                  )
                ).toList(),
              ),
            ),
          
          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(top: BorderSide(color: Color(0xFF334155))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: "Kuch bhi poochein...",
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF475569),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => sendMessage(_controller.text),
                  child: Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _messageBubble(String text, bool isBot) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(isBot) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text("⚡", style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isBot ? const Color(0xFF1E293B) : const Color(0xFF3B82F6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isBot ? 4 : 12),
                  topRight: Radius.circular(isBot ? 12 : 4),
                  bottomLeft: const Radius.circular(12),
                  bottomRight: const Radius.circular(12),
                ),
              ),
              child: Text(text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                )),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Text("⚡", style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Text("Soch raha hoon...",
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
              )),
          ),
        ],
      ),
    );
  }
}
