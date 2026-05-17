import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../main.dart';
import 'home_screen.dart';

class ResultsScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final String scenarioType;

  const ResultsScreen({super.key, required this.result, required this.scenarioType});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    bool urdu = appState.language == 'ur';
    final impact = widget.result['impact'] ?? {};
    final enrich = widget.result['enrichment'] ?? {'historical': 87, 'infra': 80, 'pop': 76};
    final beforeAfterList = widget.result['before_after'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(urdu ? "تجزیہ مکمل" : "Analysis Complete", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false), icon: const Icon(Icons.home_outlined))
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // 1. Badge
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5))),
                  child: Text(widget.result['scenario_label'] ?? "", style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 12)),
                ).animate().fadeIn().slideY(),

                // 2. INSIGHT Card
                _buildResultCard(
                  title: urdu ? "💡 تجزیہ" : "💡 INSIGHT",
                  color: const Color(0xFF3B82F6),
                  child: Text(widget.result['insight'] ?? "", style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white)),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 12),

                // 3. IMPACT Card
                _buildResultCard(
                  title: urdu ? "📈 تِجارتی اثر" : "📈 BUSINESS IMPACT",
                  color: const Color(0xFFF59E0B),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _metricCol("${impact['financial_display']}", urdu ? "ماالی خطرہ" : "FINANCIAL RISK"),
                          _metricCol("${impact['units_value']}", impact['units_label']),
                          _metricCol("${impact['severity_score']}/10", urdu ? "شدت اسکور" : "SEVERITY"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: (impact['severity_score'] ?? 0) / 10, minHeight: 6, backgroundColor: const Color(0xFF0F172A), valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B))),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 12),

                // 4. ACTION Card
                _buildResultCard(
                  title: urdu ? "✅ عمل درآمد" : "✅ ACTION EXECUTED",
                  color: const Color(0xFF10B981),
                  child: Text(widget.result['action_executed'] ?? "", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 12),

                // 5. BEFORE/AFTER TABLE
                _buildResultCard(
                  title: urdu ? "📊 تقابلی جائزہ" : "📊 BEFORE vs AFTER STATE",
                  color: const Color(0xFF94A3B8),
                  child: Table(
                    children: [
                      TableRow(children: [ _cell(urdu ? "میار" : "METRIC", isHead: true), _cell(urdu ? "پہلے" : "BEFORE", isHead: true), _cell(urdu ? "بعد" : "AFTER", isHead: true) ]),
                      ...beforeAfterList.map((row) {
                        return _tableRow(row['metric'], row['before'], row['after']);
                      }).toList(),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 12),

                // 6. KNOWLEDGE ENRICHMENT
                _buildResultCard(
                  title: urdu ? "🔍 خودکار علم کا اضافہ" : "🔍 AUTONOMOUS ENRICHMENT",
                  color: const Color(0xFF3B82F6),
                  child: Column(
                    children: [
                      _enrichRow(urdu ? "تاریخی مماثلت" : "Historical Match", enrich['historical'], const Color(0xFFEF4444)),
                      _enrichRow(urdu ? "بنیادی ڈھانچہ" : "Infrastructure Status", enrich['infra'], const Color(0xFF10B981)),
                      _enrichRow(urdu ? "آبادی پر اثر" : "Population Impact", enrich['pop'], const Color(0xFF3B82F6)),
                    ],
                  ),
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 12),

                // 7. NOTIFICATIONS
                _buildResultCard(
                  title: urdu ? "📩 اِطلاعات" : "📩 NOTIFICATIONS",
                  color: const Color(0xFF10B981),
                  child: GridView.count(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, childAspectRatio: 3,
                    children: [ _notif("📧 Gmail", "Sent"), _notif("🐦 Twitter", "Drafted"), _notif("💼 LinkedIn", "Ready"), _notif("💬 WhatsApp", "Sent") ],
                  ),
                ).animate().fadeIn(delay: 1200.ms),

                const SizedBox(height: 12),

                // 8. EXPORT GRID
                Container(
                  padding: const EdgeInsets.all(8),
                  child: GridView.count(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, childAspectRatio: 3.5, crossAxisSpacing: 8, mainAxisSpacing: 8,
                    children: [
                      _exportBtn("📄 Share Report"), _exportBtn("📊 Copy Text"), _exportBtn("💬 WhatsApp"), _exportBtn("✉️ Email"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                const Text("⚡ Powered by Gemini AI", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                Color(0xFF3B82F6),
                Color(0xFF10B981),
                Color(0xFFF59E0B),
                Color(0xFFEF4444),
                Colors.white,
              ],
              numberOfParticles: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({required String title, required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _metricCol(String val, String lab) {
    return Column(children: [ Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(lab, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))) ]);
  }

  TableRow _tableRow(String? l, String? b, String? a) {
    if (l == null) return const TableRow(children: [SizedBox(), SizedBox(), SizedBox()]);
    return TableRow(children: [ _cell(l), _cell(b ?? "", isRed: true), _cell(a ?? "", isGreen: true) ]);
  }

  Widget _cell(String t, {bool isHead = false, bool isRed = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(t, style: TextStyle(fontSize: 11, fontWeight: isHead ? FontWeight.bold : FontWeight.normal, color: isRed ? const Color(0xFFEF4444) : (isGreen ? const Color(0xFF10B981) : (isHead ? const Color(0xFF94A3B8) : Colors.white)))),
    );
  }

  Widget _enrichRow(String label, int val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text(label, style: const TextStyle(fontSize: 11)), Text("$val%", style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)) ]),
          const SizedBox(height: 4),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: val / 100, minHeight: 4, backgroundColor: const Color(0xFF0F172A), valueColor: AlwaysStoppedAnimation(color))),
        ],
      ),
    );
  }

  Widget _notif(String l, String s) {
    return Row(children: [ Text(l, style: const TextStyle(fontSize: 11)), const SizedBox(width: 8), Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF10B981))) ]);
  }

  Widget _exportBtn(String t) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)), borderRadius: BorderRadius.circular(8)),
      child: Center(child: Text(t, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.bold))),
    );
  }
}
