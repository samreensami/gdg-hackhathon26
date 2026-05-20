import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotScreen extends StatefulWidget {
  final String province;
  const ChatbotScreen({
    super.key,
    this.province = 'all'
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScolllController();

  // FIX: Pehle initState aur yahan dono jagah add ho raha tha, ab sirf yahan aik dafa rakha hai
  List<Map<String, String>> messages = [
    {
      'role': 'bot',
      'text': 'Assalam o Alaikum! 🤖\n\nI am InsightFlow AI Assistant.\n\nAsk me about Pakistan business risks, scenarios, or app features!'
    }
  ];
  bool isLoading = false;

  final List<String> quickQuestions = [
    'What is InsightFlow AI?',
    'How does it work?',
    'Flood risk in Sindh?',
    'Punjab load shedding?',
    'What scenarios available?',
    'How to run analysis?',
  ];

  // FAQ Database
  String getFAQAnswer(String message, String province) {
    final msg = message.toLowerCase();

    if(msg.contains('hi') || msg.contains('hello') || msg.contains('assalam') || msg.contains('salam')) {
      return "Assalam o Alaikum! I am InsightFlow AI Assistant 🤖\n\nI can help you with:\n• Pakistan business risks\n• Supply Chain, Flood, Load Shedding\n• Financial & Policy analysis\n• App features\n\nWhat would you like to know?";
    }
    if(msg.contains('what is') || msg.contains('insightflow') || msg.contains('kya hai')) {
      return "⚡ InsightFlow AI is Pakistan's first bilingual Autonomous Business AI Agent!\n\nBuilt by Team FireCoders for AISeekho 2026 on Google Antigravity.\n\nIt analyzes unstructured reports and takes automated actions using 3 AI agents:\n🔍 Gatekeeper → 🧠 Analyst → ⚡ Executor";
    }
    if(msg.contains('how does') || msg.contains('how it') || msg.contains('kaise') || msg.contains('kaam')) {
      return "🤖 InsightFlow AI works in 3 steps:\n\n1️⃣ Agent 1 (Gatekeeper)\nScans your report & detects urgency\n\n2️⃣ Agent 2 (Analyst)\nFinds insights using live Pakistan data\n\n3️⃣ Agent 3 (Executor)\nTakes action - sends Gmail alerts, creates notifications, shows Before/After results!";
    }
    if(msg.contains('how to run') || msg.contains('run analysis') || msg.contains('start') || msg.contains('shuru')) {
      return "▶️ To run analysis:\n\n1. Select Province filter\n2. Choose a scenario card\n3. Tap 'RUN ANALYSIS' button\n4. Watch 3 agents work live!\n5. See results with PKR impact\n\nTry Flood Warning or Supply Chain!";
    }
    if(msg.contains('scenario') || msg.contains('option') || msg.contains('feature')) {
      return "📊 InsightFlow AI has 5 Pakistan scenarios:\n\n🏭 Supply Chain Crisis\n→ Karachi port, fuel prices\n\n🌊 Flood Warning\n→ Sindh, River Indus\n\n⚡ Load Shedding\n→ Punjab factories\n\n💰 Financial Alert\n→ Lahore sales drop\n\n📰 Policy News\n→ Government levies\n\nEach gives different AI analysis!";
    }
    if(msg.contains('supply') || msg.contains('chain') || msg.contains('delivery') || msg.contains('logistics') || msg.contains('karachi')) {
      return "🏭 Supply Chain Crisis - Karachi:\n\n• Fuel prices rose 23%\n• 340 orders delayed\n• 47 vehicles stuck\n• PKR 2.3M at risk\n\n✅ InsightFlow AI Action:\nActivated alternate route via Motorway M-9\nSaved PKR 328,000!\n\nRun Supply Chain scenario for full analysis!";
    }
    if(msg.contains('flood') || msg.contains('rain') || msg.contains('river') || msg.contains('ndma') || msg.contains('sindh')) {
      return "🌊 Flood Warning - Sindh:\n\n• River Indus 85% above normal\n• 47 trucks on M-9 at risk\n• 3 warehouses need evacuation\n• PKR 450M inventory at risk\n• 2.3M people affected\n\n✅ InsightFlow AI Action:\nEmergency Protocol Alpha activated\nRerouted via N-55 highway!\n\nRun Flood Warning scenario!";
    }
    if(msg.contains('load') || msg.contains('shedding') || msg.contains('wapda') || msg.contains('electricity') || msg.contains('power') || msg.contains('punjab') || msg.contains('lahore') || msg.contains('faisalabad')) {
      return "⚡ Load Shedding - Punjab:\n\n• WAPDA: 8 hour outages\n• 23 factories affected\n• 1,847 workers idle\n• PKR 180M exports at risk\n\n✅ InsightFlow AI Action:\nNight shifts activated\nInternational clients notified\nDeadlines secured!\n\nRun Load Shedding scenario!";
    }
    if(msg.contains('financial') || msg.contains('money') || msg.contains('sales') || msg.contains('revenue') || msg.contains('pkr') || msg.contains('rupee')) {
      return "💰 Financial Alert - Lahore:\n\n• Q4 sales dropped 25%\n• 3 major clients at risk\n• PKR 45M revenue at risk\n• Competitor pricing threat\n\n✅ InsightFlow AI Action:\n15% discount campaign launched\nClient retention strategy activated!\n\nRun Financial Alert scenario!";
    }
    if(msg.contains('policy') || msg.contains('government') || msg.contains('islamabad') || msg.contains('federal') || msg.contains('levy')) {
      return "📰 Policy News - Islamabad:\n\n• Petroleum levy +15%\n• 2,300+ companies affected\n• PKR 2.8M extra cost\n\n✅ InsightFlow AI Action:\nDelivery pricing updated\nCustomers notified via SMS!\n\nRun Policy News scenario!";
    }
    if(msg.contains('kpk') || msg.contains('peshawar') || msg.contains('swat')) {
      return "🏔️ KPK Province:\n\n• Peshawar trade routes disrupted\n• Swat tourism affected\n• Mountain flooding risk\n• Agricultural supply chains at risk\n\n✅ InsightFlow AI helps:\nReroute logistics\nProtect agricultural supply chains\n\nRun Flood Warning for KPK!";
    }
    if(msg.contains('balochistan') || msg.contains('quetta') || msg.contains('gwadar') || msg.contains('cpec')) {
      return "🏜️ Balochistan:\n\n• Gwadar port disruptions\n• CPEC route challenges\n• Mining sector affected\n• Seasonal flooding risk\n\n✅ InsightFlow AI helps:\nOptimize CPEC routing\nProtect cargo operations\n\nRun Supply Chain scenario!";
    }
    if(msg.contains('agent') || msg.contains('gatekeeper') || msg.contains('analyst') || msg.contains('executor')) {
      return "🤖 3 AI Agents:\n\n🔍 Agent 1: GATEKEEPER\nScans input, detects urgency (1-10 score), classifies domain\n\n🧠 Agent 2: STRATEGIC ANALYST\nFinds patterns, calculates PKR impact, selects action\n\n⚡ Agent 3: EXECUTOR\nTakes action, sends notifications, shows Before/After results!";
    }
    if(msg.contains('urdu') || msg.contains('language') || msg.contains('bilingual')) {
      return "🌐 Yes! InsightFlow AI is fully bilingual!\n\n✅ English mode\n✅ Urdu mode\n\nToggle the language button in the app header to switch between English and Urdu.\n\nAll scenarios, results & notifications work in both languages!";
    }
    if(msg.contains('gmail') || msg.contains('email') || msg.contains('notification')) {
      return "📧 Notification System:\n\nInsightFlow AI automatically dispatches:\n• 📧 Gmail alerts\n• 🐦 Twitter posts\n• 💼 LinkedIn updates\n• 💬 WhatsApp messages\n\nAll notifications are drafted by Agent 3 when critical situations are detected!";
    }
    if(msg.contains('download') || msg.contains('share') || msg.contains('report') || msg.contains('copy')) {
      return "📊 Share Results:\n\nAfter analysis completes:\n• 📋 Copy Report button\n• 💬 WhatsApp Share button\n• 📧 Email Report option\n\nFull PKR impact, Before/After table, and agent logs can be shared instantly!";
    }
    if(msg.contains('antigravity') || msg.contains('google') || msg.contains('platform')) {
      return "🚀 Google Antigravity:\n\nInsightFlow AI is built on Google Antigravity - an agentic AI orchestration platform.\n\nAntigravity coordinates all 3 agents, manages tool calls, and enables real-time decision making.\n\nIt's the backbone of our autonomous system!";
    }
    if(msg.contains('team') || msg.contains('firecoders') || msg.contains('hackathon') || msg.contains('aiseekho')) {
      return "👥 Team FireCoders:\n\nBuilt InsightFlow AI for AISeekho 2026 Google Antigravity Hackathon!\n\n🏆 Challenge 1: Autonomous Content-to-Action Agent\n\n🇵🇰 Pakistan's first bilingual autonomous business AI with 5 real Pakistan scenarios!";
    }
    return "🤖 I can help with:\n\n• 🏭 Supply Chain Crisis\n• 🌊 Flood Warning (Sindh)\n• ⚡ Load Shedding (Punjab)\n• 💰 Financial Alert\n• 📰 Policy News\n• 🗺️ Province insights\n• ⚙️ App features\n\nWhat would you like to know?";
  }

  Future<void> sendMessage(String text) async {
    if(text.trim().isEmpty) return;

    _controller.clear();
    setState(() {
      messages.add({
        'role': 'user',
        'text': text
      });
      isLoading = true;
    });

    scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 800));
    final reply = getFAQAnswer(text, widget.province);

    setState(() {
      messages.add({
        'role': 'bot',
        'text': reply
      });
      isLoading = false;
    });

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
  void initState() {
    super.initState();
    // FIX: Duplicate initialization hata di yahan se taake screen open hote hi do do messages na dikhein
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1F35),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('🤖', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Assistant',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
                Text('InsightFlow AI',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00D4FF),
                    fontSize: 11,
                  )),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if(i == messages.length) {
                  return _thinkingWidget();
                }
                final msg = messages[i];
                final isBot = msg['role'] == 'bot';
                return _messageBubble(
                  msg['text'] ?? '',
                  isBot,
                );
              },
            ),
          ),

          if(messages.length <= 1)
            Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: quickQuestions
                  .map((q) => GestureDetector(
                    onTap: () => sendMessage(q),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
                      ),
                      child: Text(q,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00D4FF),
                          fontSize: 12,
                        )),
                    ),
                  )).toList(),
              ),
            ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1F35),
              border: Border(top: BorderSide(color: Color(0xFF1E3A5F))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask anything...',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF020B18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF00D4FF)),
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
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF0066CC)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(23)),
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
              width: 32, height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0066CC)]),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          
          // FIX SUMMARY: Added Expanded + LayoutBuilder constraint structure to prevent UI breaks
          Expanded( 
            child: Align(
              alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                constraints: BoxConstraints(
                  // Screen width ka maximum 75% space consume karega taake visual hierarchy bani rahe
                  maxWidth: MediaQuery.of(context).size.width * 0.75, 
                ),
                decoration: BoxDecoration(
                  color: isBot ? const Color(0xFF0D1F35) : const Color(0xFF00D4FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isBot ? 4 : 16),
                    topRight: Radius.circular(isBot ? 16 : 4),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: const Radius.circular(16),
                ),
                border: isBot ? Border.all(color: const Color(0xFF1E3A5F)) : null,
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.6,
                ),
                softWrap: true, // Line breaks automatically handle karega
              ),
            ),
          ),
         ),
        ],
      ),
    );
  }

  Widget _thinkingWidget() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0066CC)]),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1F35),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: const Color(0xFF1E3A5F)),
            ),
            child: Row(
              children: [
                Text('Thinking',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00D4FF),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  )),
                const SizedBox(width: 6),
                const SizedBox(
                  width: 20,
                  child: LinearProgressIndicator(
                    color: Color(0xFF00D4FF),
                    backgroundColor: Color(0xFF1E3A5F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}