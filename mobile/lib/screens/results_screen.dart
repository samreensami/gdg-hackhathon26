import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
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

                // --- DONUT CHART (NEW) ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "VALUE AT RISK BREAKDOWN",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 50,
                            sections: [
                              PieChartSectionData(
                                value: 40,
                                title: '40%',
                                color: const Color(0xFFEF4444),
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                value: 30,
                                title: '30%',
                                color: const Color(0xFFF59E0B),
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                value: 20,
                                title: '20%',
                                color: const Color(0xFF3B82F6),
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                value: 10,
                                title: '10%',
                                color: const Color(0xFF10B981),
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _legendItem(const Color(0xFFEF4444), 'Revenue Loss', '40%'),
                          _legendItem(const Color(0xFFF59E0B), 'Delay Cost', '30%'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _legendItem(const Color(0xFF3B82F6), 'Customer', '20%'),
                          _legendItem(const Color(0xFF10B981), 'Recoverable', '10%'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms),

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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: GestureDetector(onTap: () => _showNotificationDetail('Gmail'), child: _notif("📧 Gmail", "Sent", const Color(0xFF3B82F6)))),
                          const SizedBox(width: 8),
                          Expanded(child: GestureDetector(onTap: () => _showNotificationDetail('Twitter'), child: _notif("🐦 Twitter", "Drafted", const Color(0xFF1DA1F2)))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: GestureDetector(onTap: () => _showNotificationDetail('LinkedIn'), child: _notif("💼 LinkedIn", "Ready", const Color(0xFF0077B5)))),
                          const SizedBox(width: 8),
                          Expanded(child: GestureDetector(onTap: () => _showNotificationDetail('WhatsApp'), child: _notif("💬 WhatsApp", "Sent", const Color(0xFF25D366)))),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1200.ms),

                const SizedBox(height: 20),

                // 8. FINAL ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareReport(),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text("Share Report"),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyReport(),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text("Copy Report"),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareWhatsApp(),
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text("Share on WhatsApp"),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),

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
                const SizedBox(height: 10),
                const Text("⚡ InsightFlow AI | Team FireCoders", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _notif(String l, String s, Color c) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withOpacity(0.3))),
      child: Row(children: [ Text(l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), const Spacer(), Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF10B981))) ]),
    );
  }

  Widget _legendItem(Color color, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(child: Text('$label: $value', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  void _shareReport() {
    final res = widget.result;
    final text = '''
⚡ InsightFlow AI Report - FireCoders
=====================================
${res['scenario_label'] ?? 'ANALYSIS'}

💡 INSIGHT:
${res['insight'] ?? 'N/A'}

⚠️ BUSINESS IMPACT:
${res['impact']?['financial_display'] ?? 'N/A'}

✅ ACTION TAKEN:
${res['action_executed'] ?? 'N/A'}

Powered by Google Antigravity
AISeekho 2026 | Team FireCoders
''';
    Share.share(text);
  }

  void _copyReport() {
    final res = widget.result;
    final text = '''
InsightFlow AI - FireCoders
${res['scenario_label']}
Insight: ${res['insight']}
Impact: ${res['impact']?['financial_display']}
Action: ${res['action_executed']}
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report copied!'), backgroundColor: Color(0xFF10B981)));
  }

  void _shareWhatsApp() {
    final res = widget.result;
    final text = Uri.encodeComponent('''
⚡ *InsightFlow AI Alert*
*Team FireCoders | AISeekho 2026*

*${res['scenario_label']}*

💡 *Insight:*
${res['insight']}

⚠️ *Impact:* ${res['impact']?['financial_display']}
✅ *Action:* ${res['action_executed']}

_Powered by Google Antigravity_ 🚀
''');
    final url = 'https://wa.me/?text=$text';
    launchUrl(Uri.parse(url));
  }

  void _showNotificationDetail(String platform) {
    final res = widget.result;
    String message = '';
    if (platform == 'Gmail') {
      message = "Subject: URGENT - ${res['scenario_label']}\n\nDear Team,\n\nInsightFlow AI has detected a critical situation.\n\nInsight: ${res['insight']}\nImpact: ${res['impact']?['financial_display']}\nAction Taken: ${res['action_executed']}\n\nTeam FireCoders | AISeekho 2026";
    } else if (platform == 'Twitter') {
      message = "🚨 Alert: ${res['scenario_label']}\n\n${res['insight']}\n\nAction taken: ${res['action_executed']}\n\n#AISeekho2026 #InsightFlowAI #Pakistan";
    } else if (platform == 'LinkedIn') {
      message = "InsightFlow AI just detected and resolved:\n\n${res['scenario_label']}\n\nInsight: ${res['insight']}\nImpact: ${res['impact']?['financial_display']}\nAction: ${res['action_executed']}\n\nTeam FireCoders | AISeekho 2026 🚀";
    } else if (platform == 'WhatsApp') {
      message = "⚡ InsightFlow AI Alert\n${res['scenario_label']}\n${res['insight']}\nAction: ${res['action_executed']}";
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('$platform Message', style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(child: Text(message, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!'), backgroundColor: Color(0xFF10B981)));
            },
            child: const Text('Copy', style: TextStyle(color: Color(0xFF3B82F6))),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: Color(0xFF94A3B8)))),
        ],
      ),
    );
  }

  Widget _exportBtn(String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (label.contains('Share Report')) {
            _shareReport();
          } else if (label.contains('Copy')) {
            _copyReport();
          } else if (label.contains('WhatsApp')) {
            _shareWhatsApp();
          } else if (label.contains('Email')) {
            _showNotificationDetail('Gmail');
          }
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
