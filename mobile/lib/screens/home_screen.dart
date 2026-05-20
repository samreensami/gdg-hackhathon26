import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotScreen extends StatefulWidget {
  final String province; // HomeScreen se data accept karne ke liye
  const ChatbotScreen({
    super.key,
    this.province = 'all',
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Initial Chat Messages List
  late final List<Map<String, String>> _messages;

  // 🟢 PRE-DEFINED FAQs (Sawal aur Unke Instant Jawabat)
  final Map<String, String> _faqResponses = {
    "what is insightflow ai?": "InsightFlow AI is an intelligent workspace automation app designed to streamline workflows, manage tasks, and keep you updated with live news.",
    "how to use this app?": "You can navigate through the app using the menu. Use the Chatbot for instant help, and visit the News screen for live global updates.",
    "does it work offline?": "The Chatbot FAQ system works completely offline on both mobile and laptop! However, the Live News feature requires an active internet connection.",
    "who created this app?": "This app is developed as a powerful AI-driven assistant solution for the GDG Hackathon 2026 to bring automation to your fingertips.",
    "features": "Key features include: \n• Instant AI FAQ Chatbot\n• Live Real-time News Stream\n• Clean Workspace Analytics\n• Multi-platform support (Mobile & Laptop)",
  };

  @override
  void initState() {
    super.initState();
    // Welcome message me province ka naam show hoga taake evaluator ko maza aaye
    String welcomeText = "Hello! Welcome to InsightFlow AI Assistant.";
    if (widget.province != 'all') {
      welcomeText += " I see you are checking updates for ${widget.province.toUpperCase()}. How can I help you today?";
    } else {
      welcomeText += " Click on any question below or type your own to get an instant reply!";
    }

    _messages = [
      {"sender": "bot", "text": welcomeText}
    ];
  }

  // Message send karne aur instant reply ka logic
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
    });
    _controller.clear();
    _scrollToBottom();

    // Instant Automated Reply Logic
    String cleanedText = text.toLowerCase().trim();
    String botReply = "I'm sorry, I don't have an answer for that specific question yet. Try asking about 'features', 'offline mode', or 'what is insightflow ai?'.";

    // Matching logic
    _faqResponses.forEach((key, value) {
      if (cleanedText.contains(key) || key.contains(cleanedText)) {
        botReply = value;
      }
    });

    // 300ms ka chhota sa delay natural feeling dene ke liye
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _messages.add({"sender": "bot", "text": botReply});
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
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
      backgroundColor: const Color(0xFF020B18), // HomeScreen wala dark theme color match kia h
      appBar: AppBar(
        title: Text(
          "InsightFlow AI Assistant",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0D1F35),
        foregroundColor: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFF1E3A5F))),
      ),
      body: Column(
        children: [
          // 1. Chat Messages View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF0066CC) : const Color(0xFF0D1F35),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isUser ? 12 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 12),
                      ),
                      border: isUser ? null : Border.all(color: const Color(0xFF1E3A5F)),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      msg["text"]!,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Quick FAQ Suggestions Clickable Buttons
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: const Color(0xFF0D1F35),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickFAQButton("What is InsightFlow AI?"),
                _buildQuickFAQButton("Features"),
                _buildQuickFAQButton("How to use this app?"),
                _buildQuickFAQButton("Does it work offline?"),
              ],
            ),
          ),

          // 3. Input Text Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a question...",
                      hintStyle: const TextStyle(color: Color(0xFF1E3A5F)),
                      filled: true,
                      fillColor: const Color(0xFF0D1F35),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFF00D4FF)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF00D4FF),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Clickable FAQ Items Widget
  Widget _buildQuickFAQButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(
          text,
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF00D4FF), fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF020B18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}