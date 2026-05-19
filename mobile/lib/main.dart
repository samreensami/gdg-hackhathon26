import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import 'dart:math' as math;

void main() {
  runApp(const MaterialApp(
    home: InsightFlowDashboardScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

// ==========================================
// 1. DASHBOARD SCREEN WITH CLEAN ANIMATIONS
// ==========================================
class InsightFlowDashboardScreen extends StatefulWidget {
  const InsightFlowDashboardScreen({Key? key}) : super(key: key);

  @override
  _InsightFlowDashboardScreenState createState() => _InsightFlowDashboardScreenState();
}

class _InsightFlowDashboardScreenState extends State<InsightFlowDashboardScreen> with TickerProviderStateMixin {
  String _activeProvince = 'all';
  String _activeLanguage = 'en';
  String _newsContent = "Click refresh to load news...";
  bool _isNewsLoading = false;

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _balloonController;
  final List<FloatingBalloonData> _liveBalloons = [];

  final String _baseUrl = "https://insightflow-ai-839657721881.asia-south1.run.app";

  @override
  void initState() {
    super.initState();
    
    // 1. Soft Pulse Animation Controller for Loading
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // 2. Smooth Balloon Floating Animation Controller
    _balloonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {}); // Repaint balloons smoothly
      });

    _fetchLiveNews(_activeProvince);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _balloonController.dispose();
    super.dispose();
  }

  // Trigger professional floating elements on selecting scenarios
  void _triggerAnalysisSimulation(String scenario) {
    _liveBalloons.clear();
    final random = math.Random();
    
    // Create professional metrics instead of random toy shapes
    List<String> riskMetrics = ["PKR 2.5M Loss", "Supply Chain Delay", "Operational Halt", "85% Risk Score"];
    
    for (int i = 0; i < riskMetrics.length; i++) {
      _liveBalloons.add(FloatingBalloonData(
        label: riskMetrics[i],
        startX: 40.0 + random.nextDouble() * 260.0,
        speedFactor: 0.6 + random.nextDouble() * 0.5,
        color: i % 2 == 0 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
      ));
    }
    
    _balloonController.forward(from: 0.0);
  }

  Future<void> _fetchLiveNews(String province) async {
    setState(() {
      _isNewsLoading = true;
      _newsContent = _activeLanguage == 'en' ? "Fetching latest micro-risk alerts..." : "Taza tareen alerts load ho rahe hain...";
    });

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": "Give me a short direct breaking news summary for business risks.",
          "province": province,
          "language": _activeLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _newsContent = data['reply'] ?? data['text'] ?? "No active alerts found.";
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      setState(() {
        _newsContent = _activeLanguage == 'en'
            ? "⚠️ News pipeline syncing timed out. Please check backend status."
            : "⚠️ Backend se rabta nahi ho saka. Refresh kar ke check karein.";
      });
    } finally {
      setState(() {
        _isNewsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text(
          "InsightFlow AI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _activeLanguage = _activeLanguage == 'en' ? 'ur' : 'en';
              });
              _fetchLiveNews(_activeProvince);
            },
            child: Text(
              _activeLanguage == 'en' ? "اردو" : "English",
              style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )
        ],
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main Body Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🗺️ PROVINCE FILTER",
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['all', 'sindh', 'punjab', 'kpk', 'balochistan', 'federal'].map((prov) {
                    final isSelected = _activeProvince == prov;
                    return ChoiceChip(
                      label: Text(prov.toUpperCase()),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0EA5E9),
                      backgroundColor: const Color(0xFF1E293B),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold),
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _activeProvince = prov;
                          });
                          _fetchLiveNews(prov);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _activeLanguage == 'en' ? "📰 LIVE NEWS ALERT" : "📰 TAZA TAREEN KHABREIN",
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF0EA5E9)),
                      onPressed: () => _fetchLiveNews(_activeProvince),
                    )
                  ],
                ),
                
                // Animated Pulse Effect for Live News Container
                FadeTransition(
                  opacity: _isNewsLoading ? _pulseController : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isNewsLoading ? const Color(0xFF0EA5E9) : const Color(0xFF334155), width: 1),
                    ),
                    child: Text(
                      _newsContent,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "🚨 SELECT SCENARIO MATRIX (Click to Analyze)",
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 12),
                _buildScenarioCard("Supply Chain Crisis", "CRITICAL", Colors.redAccent),
                _buildScenarioCard("Flood Warning Matrix", "EMERGENCY", Colors.orangeAccent),
              ],
            ),
          ),

          // CLEAN ANIMATION LAYER: Floating balloons only draw when active animation runs
          if (_balloonController.isAnimating)
            ..._liveBalloons.map((balloon) {
              // Calculate vertical lift animation smoothly
              double screenHeight = MediaQuery.of(context).size.height;
              double currentY = screenHeight - (_balloonController.value * screenHeight * balloon.speedFactor);
              double opacity = (1.0 - _balloonController.value).clamp(0.0, 1.0);

              return Positioned(
                left: balloon.startX,
                top: currentY,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: balloon.color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: balloon.color.withOpacity(0.5), blurRadius: 8)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.blur_on, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          balloon.label,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0EA5E9),
        child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsightFlowChatScreen(
                province: _activeProvince,
                language: _activeLanguage,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScenarioCard(String title, String tag, Color tagColor) {
    return InkWell(
      onTap: () => _triggerAnalysisSimulation(title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tagColor.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: tagColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(tag, style: TextStyle(color: tagColor, fontSize: 11, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

class FloatingBalloonData {
  final String label;
  final double startX;
  final double speedFactor;
  final Color color;

  FloatingBalloonData({required this.label, required this.startX, required this.speedFactor, required this.color});
}

// ==========================================
// 2. CHATBOT SCREEN (RESPONSIVE & CLEAN)
// ==========================================
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

  final String _backendUrl = "https://insightflow-ai-839657721881.asia-south1.run.app/chat"; 

  @override
  void initState() {
    super.initState();
    String initialGreeting = widget.language == 'en'
        ? "Hello! I am your InsightFlow AI Consultant. Ask me anything about Pakistan's business and operational risks."
        : "Assalam o Alaikum! Main InsightFlow AI Assistant hoon. Pakistan ke business problems ke baare mein poochein!";
    _messages.add({"sender": "bot", "text": initialGreeting});
  }

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
        final botReply = data['reply'] ?? data['text'] ?? "No response layer parsed.";
        setState(() {
          _messages.insert(0, {"sender": "bot", "text": botReply});
        });
      } else {
        throw Exception();
      }
    } catch (e) {
      setState(() {
        String errorMsg = widget.language == 'en'
            ? "⚠️ **Connection Error:** Failed to reach the AI Risk Engine."
            : "⚠️ **Connection Error:** Backend server se sync nahi ho saka.";
        _messages.insert(0, {"sender": "bot", "text": errorMsg});
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
        title: Text(
          widget.language == 'en' ? "AI Risk Consultant" : "AI Assistant",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(color: Colors.white),
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
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      child: isUser 
                        ? Text(msg["text"]!, style: const TextStyle(color: Colors.white, fontSize: 15))
                        : MarkdownBody(
                            data: msg["text"]!,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                              strong: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                              bullet: const TextStyle(color: Color(0xFF0EA5E9)),
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
                      decoration: InputDecoration(
                        hintText: widget.language == 'en' ? "Ask about business risks..." : "Kuch bhi poochein...",
                        hintStyle: const TextStyle(color: Colors.white60, fontSize: 14),
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