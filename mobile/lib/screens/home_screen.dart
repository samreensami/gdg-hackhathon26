import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../main.dart';
import 'chatbot_screen.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedScenario = "SUPPLY_CHAIN";
  String selectedTitle = "Supply Chain Crisis";
  String _timeString = "";
  final TextEditingController _textController = TextEditingController();
  List<Map<String, String>> _newsArticles = [];
  bool _newsLoading = false;

  final Map<String, Map<String, dynamic>> provinceConfig = {
    'all': {
      'label': '🇵🇰 All',
      'color': const Color(0xFF3B82F6),
      'cities': 'All Pakistan',
      'risk': 'Complete coverage',
      'news': 'Pakistan business'
    },
    'sindh': {
      'label': '🌊 Sindh',
      'color': const Color(0xFF06B6D4),
      'cities': 'Karachi, Hyderabad',
      'risk': 'Flood, Supply Chain',
      'news': 'Karachi Sindh flood'
    },
    'punjab': {
      'label': '⚡ Punjab',
      'color': const Color(0xFFF59E0B),
      'cities': 'Lahore, Faisalabad',
      'risk': 'Load shedding, Exports',
      'news': 'Lahore Punjab WAPDA'
    },
    'kpk': {
      'label': '🏔️ KPK',
      'color': const Color(0xFF10B981),
      'cities': 'Peshawar, Swat',
      'risk': 'Flooding, Roads',
      'news': 'Peshawar KPK flood'
    },
    'balochistan': {
      'label': '🏜️ Balo...',
      'color': const Color(0xFFEF4444),
      'cities': 'Quetta, Gwadar',
      'risk': 'CPEC, Flooding',
      'news': 'Gwadar Balochistan'
    },
    'islamabad': {
      'label': '🏛️ Federal',
      'color': const Color(0xFF8B5CF6),
      'cities': 'Islamabad, RWP',
      'risk': 'Policy, Finance',
      'news': 'Islamabad policy PKR'
    },
  };

  String selectedProvince = 'all';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() => _newsLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('https://insightflow-ai-839657721881.asia-south1.run.app/news'),
      ).timeout(const Duration(seconds: 10));
      
      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = data['articles'] as List;
        
        setState(() {
          _newsArticles = articles
            .map((a) => {
              'title': a['title']?.toString() ?? '',
              'source': a['source']?.toString() ?? '',
              'published': a['published']?.toString() ?? '',
            })
            .toList();
          _newsLoading = false;
        });
      } else {
        setState(() => _newsLoading = false);
      }
    } catch(e) {
      setState(() => _newsLoading = false);
    }
  }

  Future<void> fetchNewsForProvince(String topic) async {
    setState(() => _newsLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://insightflow-ai-839657721881.asia-south1.run.app/news?topic=' + Uri.encodeComponent(topic)),
      ).timeout(const Duration(seconds: 10));
      
      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final articles = data['articles'] as List;
        setState(() {
          _newsArticles = articles.map((a) => {
            'title': a['title']?.toString() ?? '',
            'source': a['source']?.toString() ?? '',
            'published': a['published']?.toString() ?? '',
          }).toList();
          _newsLoading = false;
        });
      }
    } catch(e) {
      setState(() => _newsLoading = false);
    }
  }

  void _updateTime() {
    if (!mounted) return;
    final String formattedTime = DateTime.now().toString().split(' ')[1].substring(0, 8);
    setState(() => _timeString = formattedTime);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    bool isUrdu = appState.isUrdu;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text("⚡", style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("InsightFlow AI",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                        const Text("Autonomous Agent System",
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                          )),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => appState.toggleLanguage(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF3B82F6)),
                        ),
                        child: Text(
                          isUrdu ? "English" : "اردو",
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 13,
                          )),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // INPUT SOURCE CARD
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    Text(
                      isUrdu ? "ان پٹ ذریعہ" : "INPUT SOURCE",
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: isUrdu ? "یہاں رپورٹ لکھیں..." : "Paste your report here...",
                        hintStyle: const TextStyle(color: Color(0xFF475569)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF334155)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF334155)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 12),
                    // PROVINCE FILTER
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("🗺️ PROVINCE FILTER",
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            )),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: provinceConfig.entries.map((entry) {
                              bool isSelected = selectedProvince == entry.key;
                              Color c = entry.value['color'];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedProvince = entry.key;
                                  });
                                  fetchNewsForProvince(entry.value['news']);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? c.withOpacity(0.2) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? c : const Color(0xFF334155),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    entry.value['label'],
                                    style: TextStyle(
                                      color: isSelected ? c : const Color(0xFF94A3B8),
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          if(selectedProvince != 'all') ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  left: BorderSide(
                                    color: provinceConfig[selectedProvince]!['color'],
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "📍 ${provinceConfig[selectedProvince]!['cities']}",
                                    style: TextStyle(
                                      color: provinceConfig[selectedProvince]!['color'],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    )),
                                  const SizedBox(height: 2),
                                  const Text(
                                    "⚠️ Regional issues active",
                                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "— OR SELECT SCENARIO —",
                      style: TextStyle(color: Color(0xFF475569), fontSize: 11),
                    ),
                  ],
                ),
              ),

              // SCENARIO CARDS
              scenarioCard("🏭", "Supply Chain Crisis", "CRITICAL", const Color(0xFFEF4444), "SUPPLY_CHAIN", "سپلائی چین بحران", isUrdu),
              scenarioCard("🌊", "Flood Warning", "EMERGENCY", const Color(0xFFEF4444), "FLOOD", "سیلاب وارننگ", isUrdu),
              scenarioCard("⚡", "Load Shedding", "HIGH", const Color(0xFFF59E0B), "LOAD_SHEDDING", "لوڈ شیڈنگ", isUrdu),
              scenarioCard("💰", "Financial Alert", "HIGH", const Color(0xFFF59E0B), "FINANCIAL", "مالی الرٹ", isUrdu),
              scenarioCard("📰", "Policy News", "MEDIUM", const Color(0xFF3B82F6), "POLICY", "پالیسی خبریں", isUrdu),

              const SizedBox(height: 12),

              // LIVE NEWS SECTION (New)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "📰 LIVE PAKISTAN NEWS",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        GestureDetector(
                          onTap: fetchNews,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF3B82F6)),
                            ),
                            child: Text(
                              _newsLoading ? "⏳ Loading" : "🔄 Refresh",
                              style: const TextStyle(
                                color: Color(0xFF3B82F6),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _newsLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6), strokeWidth: 2))
                      : _newsArticles.isEmpty
                        ? const Text("No news available", style: TextStyle(color: Color(0xFF475569), fontSize: 12))
                        : Column(
                            children: _newsArticles.take(3).map((article) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF334155), width: 0.5))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article['title'] ?? '',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "📌 ${article['source']} · ${article['published']}",
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // RUN ANALYSIS BUTTON
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: selectedScenario.isEmpty ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnalysisScreen(scenarioType: selectedScenario),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bolt, color: Colors.white, size: 20),
                  label: Text(
                    isUrdu ? "تجزیہ چلائیں" : "RUN ANALYSIS",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                    shadowColor: const Color(0xFF3B82F6).withOpacity(0.5),
                  ),
                ),
              ),

              // MCP STATUS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("MCP STATUS",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      )),
                    const SizedBox(height: 10),
                    mcpItem("Gmail API", true, const Color(0xFF10B981)),
                    mcpItem("GitHub", true, const Color(0xFF10B981)),
                    mcpItem("Google Drive", true, const Color(0xFF10B981)),
                    mcpItem("Sequential Thinking", true, const Color(0xFF3B82F6)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget scenarioCard(String icon, String title, String badge, Color badgeColor, String type, String urduTitle, bool isUrdu) {
    bool isSelected = selectedScenario == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedScenario = type;
          selectedTitle = isUrdu ? urduTitle : title;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF334155),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 8, spreadRadius: 1)
          ] : [],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isUrdu ? urduTitle : title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: badgeColor.withOpacity(0.5)),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mcpItem(String label, bool connected, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(connected ? "Connected" : "Offline",
            style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
