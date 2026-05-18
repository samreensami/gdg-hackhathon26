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
  String selectedProvince = 'all';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _fetchNews();
  }

  void _updateTime() {
    if (!mounted) return;
    final String formattedTime = DateTime.now().toString().split(' ')[1].substring(0, 8);
    setState(() => _timeString = formattedTime);
  }

  Color _getProvinceColor(String p) {
    switch(p) {
      case 'sindh': return const Color(0xFF00D4FF);
      case 'punjab': return const Color(0xFFFFB800);
      case 'kpk': return const Color(0xFF00E5A0);
      case 'balochistan': return const Color(0xFFFF4757);
      case 'islamabad': return const Color(0xFF9B59B6);
      default: return const Color(0xFF00D4FF);
    }
  }

  String _getProvinceInfo(String p) {
    switch(p) {
      case 'sindh': 
        return '📍 Karachi, Hyderabad, Sukkur\n⚠️ Flood, Supply Chain';
      case 'punjab': 
        return '📍 Lahore, Faisalabad, Multan\n⚠️ Load Shedding, Exports';
      case 'kpk': 
        return '📍 Peshawar, Swat, Abbottabad\n⚠️ Floods, Roads';
      case 'balochistan': 
        return '📍 Quetta, Gwadar, Turbat\n⚠️ CPEC, Flooding';
      case 'islamabad': 
        return '📍 Islamabad, Rawalpindi\n⚠️ Policy, Finance';
      default: return '📍 All Pakistan';
    }
  }

  Widget _provBtn(String id, String label, Color color) {
    bool isSelected = selectedProvince == id;
    return GestureDetector(
      onTap: () => _fetchNewsForProvince(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF1E3A5F),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(label,
          style: TextStyle(
            color: isSelected ? color : const Color(0xFF7BA7C4),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _fetchNews() async {
    if (!mounted) return;
    setState(() => _newsLoading = true);
    try {
      final topic = _getNewsTopic(selectedProvince);
      final res = await http.get(Uri.parse(
        'https://insightflow-ai-839657721881.asia-south1.run.app/news?topic=${Uri.encodeComponent(topic)}'
      )).timeout(const Duration(seconds: 10));
      
      if(res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final articles = data['articles'] as List;
        if (mounted) {
          setState(() {
            _newsArticles = articles.map((a) => {
              'title': a['title']?.toString() ?? '',
              'source': a['source']?.toString() ?? '',
              'published': a['published']?.toString() ?? '',
            }).toList();
          });
        }
      }
    } catch(e) {
      print('News error: $e');
    }
    if (mounted) setState(() => _newsLoading = false);
  }

  String _getNewsTopic(String province) {
    switch(province) {
      case 'sindh': return 'Karachi Sindh Pakistan';
      case 'punjab': return 'Lahore Punjab Pakistan';
      case 'kpk': return 'Peshawar KPK Pakistan';
      case 'balochistan': return 'Quetta Gwadar Pakistan';
      case 'islamabad': return 'Islamabad Pakistan policy';
      default: return 'Pakistan business economy';
    }
  }

  Future<void> _fetchNewsForProvince(String province) async {
    setState(() {
      selectedProvince = province;
    });
    await _fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    bool isUrdu = appState.isUrdu;

    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
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
                            color: Color(0xFF00D4FF),
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
                          color: const Color(0xFF0D1F35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00D4FF)),
                        ),
                        child: Text(
                          isUrdu ? "English" : "اردو",
                          style: const TextStyle(
                            color: Color(0xFF00D4FF),
                            fontSize: 13,
                          )),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PROVINCE FILTER
              Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1F35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("🗺️ PROVINCE FILTER",
                      style: TextStyle(
                        color: Color(0xFF7BA7C4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      )),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _provBtn('all', '🇵🇰 All', const Color(0xFF00D4FF)),
                        _provBtn('sindh', '🌊 Sindh', const Color(0xFF00D4FF)),
                        _provBtn('punjab', '⚡ Punjab', const Color(0xFFFFB800)),
                        _provBtn('kpk', '🏔️ KPK', const Color(0xFF00E5A0)),
                        _provBtn('balochistan', '🏜️ Balo', const Color(0xFFFF4757)),
                        _provBtn('islamabad', '🏛️ Federal', const Color(0xFF9B59B6)),
                      ],
                    ),
                    if(selectedProvince != 'all') ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020B18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border(
                            left: BorderSide(
                              color: _getProvinceColor(selectedProvince),
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          _getProvinceInfo(selectedProvince),
                          style: const TextStyle(
                            color: Color(0xFF7BA7C4),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // LIVE NEWS SECTION
              Container(
                margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1F35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("📰 LIVE NEWS",
                          style: TextStyle(
                            color: Color(0xFF7BA7C4),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          )),
                        GestureDetector(
                          onTap: () => _fetchNews(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
                            ),
                            child: Text(
                              _newsLoading ? '⏳' : '🔄',
                              style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _newsLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00D4FF),
                            strokeWidth: 2,
                          ))
                      : _newsArticles.isEmpty
                        ? const Text(
                            'Click refresh to load news',
                            style: TextStyle(
                              color: Color(0xFF1E3A5F),
                              fontSize: 11,
                            ))
                        : Column(
                            children: _newsArticles.take(3).map((a) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF1E3A5F),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a['title'] ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFFE8F4FD),
                                      fontSize: 11,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${a['source']} · ${a['published']}',
                                    style: const TextStyle(
                                      color: Color(0xFF7BA7C4),
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                  ],
                ),
              ),

              // INPUT SOURCE CARD
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1F35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: Column(
                  children: [
                    Text(
                      isUrdu ? "ان پٹ ذریعہ" : "INPUT SOURCE",
                      style: const TextStyle(
                        color: Color(0xFF7BA7C4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: isUrdu ? "یہاں رپورٹ لکھیں..." : "Paste your report here...",
                        hintStyle: const TextStyle(color: Color(0xFF1E3A5F)),
                        filled: true,
                        fillColor: const Color(0xFF020B18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF00D4FF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                "— OR SELECT SCENARIO —",
                style: TextStyle(color: Color(0xFF1E3A5F), fontSize: 10),
              ),
              const SizedBox(height: 8),

              // SCENARIO CARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _scenarioBtn("🏭", "Supply Chain Crisis", "CRITICAL", const Color(0xFFEF4444), "SUPPLY_CHAIN", "سپلائی چین بحران", isUrdu),
                    _scenarioBtn("🌊", "Flood Warning", "EMERGENCY", const Color(0xFFEF4444), "FLOOD", "سیلاب وارننگ", isUrdu),
                    _scenarioBtn("⚡", "Load Shedding", "HIGH", const Color(0xFFFFB800), "LOAD_SHEDDING", "لوڈ شیڈنگ", isUrdu),
                    _scenarioBtn("💰", "Financial Alert", "HIGH", const Color(0xFFFFB800), "FINANCIAL", "مالی الرٹ", isUrdu),
                    _scenarioBtn("📰", "Policy News", "MEDIUM", const Color(0xFF00D4FF), "POLICY", "پالیسی خبریں", isUrdu),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                    shadowColor: const Color(0xFF0066CC).withOpacity(0.5),
                  ),
                ),
              ),

              // MCP STATUS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1F35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E3A5F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("MCP STATUS",
                      style: TextStyle(
                        color: Color(0xFF7BA7C4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      )),
                    const SizedBox(height: 10),
                    _mcpItem("Gmail API", const Color(0xFF00E5A0)),
                    _mcpItem("GitHub", const Color(0xFF00E5A0)),
                    _mcpItem("Google Drive", const Color(0xFF00E5A0)),
                    _mcpItem("Sequential Thinking", const Color(0xFF00D4FF)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(seconds: 1),
        builder: (ctx, val, child) => Transform.scale(
          scale: val,
          child: FloatingActionButton(
            heroTag: 'chatbot_fab',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatbotScreen(
                  province: selectedProvince,
                )
              )
            ),
            backgroundColor: const Color(0xFF00D4FF),
            child: const Text('🤖',
              style: TextStyle(fontSize: 26)),
          ),
        ),
        onEnd: () => setState(() {}),
      ),
    );
  }

  Widget _scenarioBtn(
    String icon,
    String title,
    String badge,
    Color color,
    String type,
    String urdu,
    bool isUrdu
  ) {
    bool isSelected = selectedScenario == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedScenario = type;
          selectedTitle = isUrdu ? urdu : title;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFF020B18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF1E3A5F),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
            )
          ] : [],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isUrdu ? urdu : title,
                style: const TextStyle(
                  color: Color(0xFFE8F4FD),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mcpItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
              style: const TextStyle(
                color: Color(0xFF7BA7C4),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('✓',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            )),
        ],
      ),
    );
  }
}
