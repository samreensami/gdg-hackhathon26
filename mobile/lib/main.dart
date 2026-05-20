import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashScreen(),
      '/onboarding': (context) => const OnboardingScreen(),
      '/dashboard': (context) => const InsightFlowDashboardScreen(),
    },
    debugShowCheckedModeBanner: false,
  ));
}


class InsightFlowDashboardScreen
  extends StatefulWidget {
  const InsightFlowDashboardScreen({Key? key})
    : super(key: key);

  @override
  _InsightFlowDashboardScreenState createState()
    => _InsightFlowDashboardScreenState();
}

class _InsightFlowDashboardScreenState
  extends State<InsightFlowDashboardScreen>
  with TickerProviderStateMixin {

  String _activeProvince = 'all';
  String _activeLanguage = 'en';
  String _newsContent =
    "Click refresh to load news...";
  bool _isNewsLoading = false;

  late AnimationController _pulseController;
  late AnimationController _balloonController;
  final List<FloatingBalloonData> _liveBalloons = [];

  final String _baseUrl =
    "https://insightflow-ai-839657721881.asia-south1.run.app";

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _balloonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {});
      });

    _fetchLiveNews(_activeProvince);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _balloonController.dispose();
    super.dispose();
  }

  void _triggerAnalysisSimulation(
    String scenario) {
    _liveBalloons.clear();
    final random = math.Random();
    List<String> riskMetrics = [
      "PKR 2.5M Loss",
      "Supply Chain Delay",
      "Operational Halt",
      "85% Risk Score"
    ];
    for (int i = 0; i < riskMetrics.length; i++) {
      _liveBalloons.add(FloatingBalloonData(
        label: riskMetrics[i],
        startX: 40.0 + random.nextDouble() * 260.0,
        speedFactor: 0.6 + random.nextDouble() * 0.5,
        color: i % 2 == 0
          ? const Color(0xFFEF4444)
          : const Color(0xFFF59E0B),
      ));
    }
    _balloonController.forward(from: 0.0);
  }

  Future<void> _fetchLiveNews(String province) async {
    setState(() {
      _isNewsLoading = true;
      _newsContent = _activeLanguage == 'en'
        ? "Fetching latest micro-risk alerts..."
        : "Taza tareen alerts load ho rahe hain...";
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      if (_activeLanguage == 'en') {
        if (province == 'sindh') _newsContent = "🔴 LIVE: Heavy rain expected in Karachi South. Port operations on alert.";
        else if (province == 'punjab') _newsContent = "🔴 LIVE: 8-hour load shedding affecting Faisalabad industrial zone.";
        else if (province == 'kpk') _newsContent = "🔴 LIVE: Peshawar highway blocked due to landslide. Logistics delayed.";
        else if (province == 'balochistan') _newsContent = "🔴 LIVE: Gwadar port facing operational delays due to weather.";
        else if (province == 'federal') _newsContent = "🔴 LIVE: Islamabad announces 15% increase in petroleum levy.";
        else _newsContent = "🔴 LIVE: Supply chain disruptions reported across major highways. PKR 2.3M at risk.";
      } else {
        if (province == 'sindh') _newsContent = "🔴 LIVE: Karachi South mein shadeed barish ki tawaqo. Port operations alert par.";
        else if (province == 'punjab') _newsContent = "🔴 LIVE: Faisalabad industrial zone mein 8 ghante ki load shedding.";
        else if (province == 'kpk') _newsContent = "🔴 LIVE: Peshawar highway landslide ki wajah se band. Logistics mein takheer.";
        else if (province == 'balochistan') _newsContent = "🔴 LIVE: Mosam ki kharabi ke baais Gwadar port par takheer.";
        else if (province == 'federal') _newsContent = "🔴 LIVE: Islamabad ne petroleum levy mein 15% izafe ka elaan kiya.";
        else _newsContent = "🔴 LIVE: Aham highways par supply chain mein masail. PKR 2.3M ka khatra.";
      }
      _isNewsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text(
          "InsightFlow AI",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _activeLanguage =
                  _activeLanguage == 'en'
                    ? 'ur' : 'en';
              });
              _fetchLiveNews(_activeProvince);
            },
            child: Text(
              _activeLanguage == 'en'
                ? "اردو" : "English",
              style: const TextStyle(
                color: Color(0xFF0EA5E9),
                fontWeight: FontWeight.bold,
                fontSize: 16),
            ),
          )
        ],
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                const Text(
                  "🗺️ PROVINCE FILTER",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'all', 'sindh', 'punjab',
                    'kpk', 'balochistan', 'federal'
                  ].map((prov) {
                    final isSelected =
                      _activeProvince == prov;
                    return ChoiceChip(
                      label: Text(
                        prov.toUpperCase()),
                      selected: isSelected,
                      selectedColor:
                        const Color(0xFF0EA5E9),
                      backgroundColor:
                        const Color(0xFF1E293B),
                      labelStyle: TextStyle(
                        color: isSelected
                          ? Colors.white
                          : Colors.white60,
                        fontWeight:
                          FontWeight.bold),
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
                  mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _activeLanguage == 'en'
                        ? "📰 LIVE NEWS ALERT"
                        : "📰 TAZA TAREEN KHABREIN",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Color(0xFF0EA5E9)),
                      onPressed: () =>
                        _fetchLiveNews(
                          _activeProvince),
                    )
                  ],
                ),
                FadeTransition(
                  opacity: _isNewsLoading
                    ? _pulseController
                    : const AlwaysStoppedAnimation(
                        1.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isNewsLoading 
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [const Color(0xFF991B1B).withAlpha(50), const Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isNewsLoading
                          ? const Color(0xFF0EA5E9).withAlpha(128)
                          : const Color(0xFFEF4444).withAlpha(128),
                        width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: _isNewsLoading ? const Color(0xFF0EA5E9).withAlpha(25) : const Color(0xFFEF4444).withAlpha(40),
                          blurRadius: 15,
                          spreadRadius: 2,
                        )
                      ]
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _isNewsLoading ? Icons.sync : Icons.campaign,
                          color: _isNewsLoading ? const Color(0xFF0EA5E9) : const Color(0xFFEF4444),
                          size: 26,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _newsContent,
                            style: TextStyle(
                              color: _isNewsLoading ? Colors.white70 : Colors.white,
                              fontSize: 15,
                              fontWeight: _isNewsLoading ? FontWeight.normal : FontWeight.w600,
                              height: 1.4,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "🚨 SELECT SCENARIO",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
                ),
                const SizedBox(height: 12),
                _buildScenarioCard(
                  "🏭 Supply Chain Crisis",
                  "CRITICAL",
                  Colors.redAccent),
                _buildScenarioCard(
                  "🌊 Flood Warning",
                  "EMERGENCY",
                  Colors.orangeAccent),
                _buildScenarioCard(
                  "⚡ Load Shedding",
                  "HIGH",
                  Colors.amber),
                _buildScenarioCard(
                  "💰 Financial Alert",
                  "HIGH",
                  Colors.yellow),
                _buildScenarioCard(
                  "📰 Policy News",
                  "MEDIUM",
                  Colors.blueAccent),
              ],
            ),
          ),
          if (_balloonController.isAnimating)
            ..._liveBalloons.map((balloon) {
              double screenHeight =
                MediaQuery.of(context).size.height;
              double currentY = screenHeight -
                (_balloonController.value *
                  screenHeight *
                  balloon.speedFactor);
              double opacity =
                (1.0 - _balloonController.value)
                  .clamp(0.0, 1.0);
              return Positioned(
                left: balloon.startX,
                top: currentY,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    padding:
                      const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: balloon.color,
                      borderRadius:
                        BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: balloon.color
                            .withOpacity(0.5),
                          blurRadius: 8)
                      ],
                    ),
                    child: Row(
                      mainAxisSize:
                        MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.blur_on,
                          color: Colors.white,
                          size: 14),
                        const SizedBox(width: 4),
                        Text(
                          balloon.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight:
                              FontWeight.bold),
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
        child: const Icon(
          Icons.smart_toy,
          color: Colors.white,
          size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                InsightFlowChatScreen(
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tagColor.withAlpha(100), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: tagColor.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tagColor.withAlpha(38),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tagColor.withAlpha(76))
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: tagColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0)
              ),
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

  FloatingBalloonData({
    required this.label,
    required this.startX,
    required this.speedFactor,
    required this.color,
  });
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
  _InsightFlowChatScreenState createState()
    => _InsightFlowChatScreenState();
}

class _InsightFlowChatScreenState
  extends State<InsightFlowChatScreen> {

  final TextEditingController _messageController
    = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final String _backendUrl =
    "https://insightflow-ai-839657721881.asia-south1.run.app/chat";

  @override
  void initState() {
    super.initState();
    String initialGreeting =
      widget.language == 'en'
        ? "Hello! I am InsightFlow AI Assistant 🤖\n\nAsk me about:\n• Supply Chain Crisis\n• Flood Warning\n• Load Shedding\n• Financial Alert\n• Policy News\n• App features"
        : "Assalam o Alaikum! Main InsightFlow AI Assistant hoon 🤖\n\nPoochein:\n• Supply Chain\n• Flood Warning\n• Load Shedding\n• Financial Alert\n• Policy News";
    _messages.add({
      "sender": "bot",
      "text": initialGreeting
    });
  }

  Future<void> _sendMessage() async {
    final userText =
      _messageController.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.insert(0, {
        "sender": "user",
        "text": userText
      });
      _isLoading = true;
    });
    _messageController.clear();

    // Natural delay to feel like AI is thinking
    await Future.delayed(const Duration(milliseconds: 600));

    final botReply = _getFAQAnswer(userText, widget.province, widget.language);

    setState(() {
      _messages.insert(0, {
        "sender": "bot",
        "text": botReply
      });
      _isLoading = false;
    });
  }

  String _getFAQAnswer(String message, String province, String language) {
    final msg = message.toLowerCase();
    
    if(msg.contains('what is') || msg.contains('insightflow') || msg.contains('kya hai')) {
      return language == 'en' ? "⚡ InsightFlow AI is Pakistan's first bilingual Autonomous Business AI Agent! Built to analyze unstructured reports and take automated actions using 3 AI agents." : "⚡ InsightFlow AI Pakistan ka pehla bilingual Autonomous Business AI Agent hai jo real-time risk analysis karta hai.";
    }
    if(msg.contains('how') || msg.contains('kaise') || msg.contains('kaam')) {
      return language == 'en' ? "🤖 It works in 3 steps:\n1️⃣ Gatekeeper: Scans urgency\n2️⃣ Analyst: Finds insights\n3️⃣ Executor: Takes action & alerts!" : "🤖 Ye 3 steps me kaam karta hai:\n1️⃣ Gatekeeper: Urgency check karta hai\n2️⃣ Analyst: Insights nikalta hai\n3️⃣ Executor: Action leta hai!";
    }
    if(msg.contains('scenario') || msg.contains('feature') || msg.contains('option')) {
      return language == 'en' ? "📊 5 Pakistan scenarios:\n🏭 Supply Chain\n🌊 Flood Warning\n⚡ Load Shedding\n💰 Financial Alert\n📰 Policy News" : "📊 5 Scenarios hain:\n🏭 Supply Chain\n🌊 Flood Warning\n⚡ Load Shedding\n💰 Financial Alert\n📰 Policy News";
    }
    if(msg.contains('supply') || msg.contains('chain')) {
      return language == 'en' ? "🏭 Supply Chain Crisis:\nAnalyzes fuel prices, delayed orders & reroutes logistics instantly." : "🏭 Supply Chain Crisis:\nFuel prices aur delayed orders ko analyze kar ke alternate route nikalta hai.";
    }
    if(msg.contains('flood') || msg.contains('rain') || msg.contains('sindh')) {
      return language == 'en' ? "🌊 Flood Warning:\nEvaluates river levels, protects inventory & sends evacuation alerts." : "🌊 Flood Warning:\nSelab ke khatre ko dekhte hue inventory bachata hai aur alerts bhejta hai.";
    }
    if(msg.contains('load') || msg.contains('shedding') || msg.contains('punjab')) {
      return language == 'en' ? "⚡ Load Shedding:\nMitigates 8-hour outages by shifting to night production to save export deadlines." : "⚡ Load Shedding:\nFactory ki production ko raat mein shift karta hai taake deadlines miss na hon.";
    }
    if(msg.contains('financial') || msg.contains('money')) {
      return language == 'en' ? "💰 Financial Alert:\nDetects sales drops and automatically launches discount campaigns." : "💰 Financial Alert:\nSales drop ko detect kar ke automatically discount campaigns start karta hai.";
    }
    if(msg.contains('policy') || msg.contains('levy') || msg.contains('government')) {
      return language == 'en' ? "📰 Policy News:\nMonitors tax changes & updates pricing models automatically." : "📰 Policy News:\nTax ya levy change hone par pricing models ko update karta hai.";
    }
    if(msg.contains('urdu') || msg.contains('language') || msg.contains('bilingual')) {
      return language == 'en' ? "🌐 Yes! InsightFlow AI is fully bilingual. Use the toggle to switch between English and Urdu." : "🌐 Jee haan! InsightFlow AI poori tarah bilingual hai. Aap kisi bhi waqt English aur Urdu mein switch kar sakte hain.";
    }
    
    return language == 'en' 
      ? "🤖 I can help with:\n• 🏭 Supply Chain\n• 🌊 Flood Warning\n• ⚡ Load Shedding\n• 💰 Financial Alert\n• 📰 Policy News\n• ⚙️ App features\n\nWhat would you like to know?"
      : "🤖 Main in cheezon mein madad kar sakta hoon:\n• 🏭 Supply Chain\n• 🌊 Flood Warning\n• ⚡ Load Shedding\n• 💰 Financial Alert\n• 📰 Policy News\n• ⚙️ App features\n\nKya janna chahte hain aap?";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language == 'en'
            ? "🤖 AI Assistant"
            : "🤖 AI Assistant",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
        iconTheme: const IconThemeData(
          color: Colors.white),
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
                  final isUser =
                    msg["sender"] == "user";
                  return Align(
                    alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets
                        .symmetric(vertical: 6),
                      padding:
                        const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser
                          ? const Color(0xFF0EA5E9)
                          : const Color(0xFF1E293B),
                        borderRadius:
                          BorderRadius.circular(12),
                      ),
                      constraints: BoxConstraints(
                        maxWidth:
                          MediaQuery.of(context)
                            .size.width * 0.78,
                      ),
                      child: Text(
                        msg["text"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 8.0),
                child: Row(
                  mainAxisAlignment:
                    MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                        AlwaysStoppedAnimation<Color>(
                          Color(0xFF0EA5E9))),
                    SizedBox(width: 12),
                    Text(
                      "Thinking...",
                      style: TextStyle(
                        color: Color(0xFF0EA5E9),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      )),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(
                        color: Colors.white),
                      onSubmitted: (_) =>
                        _sendMessage(),
                      decoration: InputDecoration(
                        hintText: widget.language == 'en'
                          ? "Ask about Pakistan risks..."
                          : "Kuch bhi poochein...",
                        hintStyle: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFF0EA5E9)),
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