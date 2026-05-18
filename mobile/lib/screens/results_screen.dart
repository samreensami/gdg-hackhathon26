import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:confetti/confetti.dart';

class ResultsScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final String scenarioType;

  const ResultsScreen({super.key, required this.result, required this.scenarioType});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ConfettiController _confettiController;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if(mounted) {
        setState(() => _showCelebration = true);
        Future.delayed(const Duration(seconds: 4), () {
          if(mounted) setState(() => _showCelebration = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final impact = result['impact'] ?? {};
    final beforeAfter = result['before_after'] as List? ?? [];
    final urgencyScore = (impact['severity_score'] ?? 0.0);
    final urgencyColor = urgencyScore > 8 ? const Color(0xFFEF4444) : (urgencyScore > 6 ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis Results"),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. SCENARIO BADGE
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: urgencyColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    result['scenario_label'] ?? 'ANALYSIS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: urgencyColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // 2. INSIGHT CARD
                resultCard(
                  title: "💡 INSIGHT",
                  titleColor: const Color(0xFF3B82F6),
                  borderColor: const Color(0xFF3B82F6),
                  content: result['insight'] ?? '',
                ),

                // 3. BUSINESS IMPACT CARD
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(left: BorderSide(color: Color(0xFFF59E0B), width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("⚠️ BUSINESS IMPACT",
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        )),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          impactMetric(impact['financial_display'] ?? 'N/A', "Value at Risk", const Color(0xFFF59E0B)),
                          impactMetric('${impact['units_value'] ?? 0}', impact['units_label'] ?? 'Affected', Colors.white),
                          impactMetric('${urgencyScore}/10', "Score", const Color(0xFFEF4444)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: urgencyScore / 10,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),

                // 4. DONUT CHART
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("📊 VALUE AT RISK BREAKDOWN",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        )),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            height: 150,
                            width: 150,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 45,
                                sections: [
                                  PieChartSectionData(value: 40, title: '40%', color: const Color(0xFFEF4444), radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                  PieChartSectionData(value: 30, title: '30%', color: const Color(0xFFF59E0B), radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                  PieChartSectionData(value: 20, title: '20%', color: const Color(0xFF3B82F6), radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                  PieChartSectionData(value: 10, title: '10%', color: const Color(0xFF10B981), radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                legendRow(const Color(0xFFEF4444), "Revenue Loss", "40%"),
                                const SizedBox(height: 8),
                                legendRow(const Color(0xFFF59E0B), "Delay Cost", "30%"),
                                const SizedBox(height: 8),
                                legendRow(const Color(0xFF3B82F6), "Customer", "20%"),
                                const SizedBox(height: 8),
                                legendRow(const Color(0xFF10B981), "Recoverable", "10%"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 5. ACTION EXECUTED
                resultCard(
                  title: "✅ ACTION EXECUTED",
                  titleColor: const Color(0xFF10B981),
                  borderColor: const Color(0xFF10B981),
                  content: result['action_executed'] ?? '',
                ),

                // 6. BEFORE vs AFTER TABLE
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text("METRIC", style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600))),
                            Expanded(child: Text("BEFORE", textAlign: TextAlign.center, style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w600))),
                            Expanded(child: Text("AFTER", textAlign: TextAlign.center, style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                      ...beforeAfter.map((row) => tableRow(row['metric'] ?? '', row['before'] ?? '', row['after'] ?? '')).toList(),
                    ],
                  ),
                ),

                // 7. NOTIFICATIONS
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("NOTIFICATIONS DISPATCHED",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        )),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 3,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          notifChip("📧", "Gmail", "Sent", const Color(0xFF3B82F6)),
                          notifChip("🐦", "Twitter", "Drafted", const Color(0xFF1DA1F2)),
                          notifChip("💼", "LinkedIn", "Ready", const Color(0xFF0077B5)),
                          notifChip("💬", "WhatsApp", "Sent", const Color(0xFF25D366)),
                        ],
                      ),
                    ],
                  ),
                ),

                // 8. SHARE/DOWNLOAD BUTTONS
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final r = widget.result;
                                final text = '''
InsightFlow AI Report - FireCoders
===================================
${r['scenario_label']}

INSIGHT: ${r['insight']}
IMPACT: ${r['impact']?['financial_display']}
ACTION: ${r['action_executed']}

AISeekho 2026 | Google Antigravity
                ''';
                                Clipboard.setData(
                                  ClipboardData(text: text));
                                ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                    content: Text('Report copied!'),
                                    backgroundColor: Color(0xFF10B981),
                                  ));
                              },
                              icon: const Icon(Icons.copy, 
                                size: 16, color: Colors.white),
                              label: const Text("Copy Report",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                )),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: 
                                    BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final r = widget.result;
                                final text = Uri.encodeComponent(
                                  '⚡ InsightFlow AI\n'
                                  '${r["scenario_label"]}\n'
                                  '${r["insight"]}\n'
                                  'Impact: ${r["impact"]?["financial_display"]}\n'
                                  'Action: ${r["action_executed"]}\n'
                                  '#AISeekho2026 🇵🇰'
                                );
                                await launchUrl(
                                  Uri.parse('https://wa.me/?text=$text'),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              icon: const Icon(Icons.share,
                                size: 16, color: Colors.white),
                              label: const Text("WhatsApp",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                )),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: 
                                    BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // 9. FOOTER
                Center(
                  child: Text(
                    "⚡ InsightFlow AI\nPowered by Google Antigravity\n🇵🇰 Team FireCoders | AISeekho 2026",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: const Color(0xFF3B82F6), fontSize: 12),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444)],
            ),
          ),
          if(_showCelebration) _buildCelebration(),
        ],
      ),
    );
  }

  Widget _buildCelebration() {
    final size = MediaQuery.of(context).size;
    final colors = [
      const Color(0xFF00D4FF), const Color(0xFFFFB800),
      const Color(0xFFFF4757), const Color(0xFF00E5A0),
      const Color(0xFF9B59B6), Colors.white,
    ];
    final emojis = [
      '🎉','🎊','🎈','🎉','🎊',
      '🎈','🎉','🎊','🎈','🎉'
    ];

    return IgnorePointer(
      child: Stack(
        children: [
          ...emojis.asMap().entries.map((e) =>
            TweenAnimationBuilder<double>(
              key: ValueKey('rb${e.key}'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(
                milliseconds: 2500 + e.key * 150),
              builder: (ctx, val, _) => Positioned(
                left: 20.0 + e.key *
                  (size.width - 40) / emojis.length,
                bottom: size.height * val - 50,
                child: Opacity(
                  opacity: val < 0.85
                    ? 1.0 : (1 - val) * 6.7,
                  child: Text(e.value,
                    style: TextStyle(
                      fontSize: 28 +
                        (e.key % 3) * 8.0)),
                ),
              ),
            ),
          ),
          ...List.generate(35, (i) =>
            TweenAnimationBuilder<double>(
              key: ValueKey('rc$i'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(
                milliseconds: 1800 + i * 45),
              builder: (ctx, val, _) => Positioned(
                left: (i * 67.0) % size.width,
                top: size.height * val,
                child: Opacity(
                  opacity: val < 0.75
                    ? 1.0 : (1 - val) * 4.0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors[i % 6],
                      shape: i % 2 == 0
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                      borderRadius: i % 2 != 0
                        ? BorderRadius.circular(2)
                        : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void showNotifDetail(String platform) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('$platform Message Preview', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: SingleChildScrollView(child: Text(getNotifText(platform), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.6))),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: getNotifText(platform)));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!'), backgroundColor: Color(0xFF10B981)));
            },
            child: const Text('Copy', style: TextStyle(color: Color(0xFF3B82F6))),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  String getNotifText(String platform) {
    final res = widget.result;
    if (platform == 'Gmail') {
      return 'Subject: URGENT - ${res['scenario_label']}\n\nDear Team,\n\nInsightFlow AI Alert:\n\nInsight: ${res['insight']}\nImpact: ${res['impact']?['financial_display']}\nAction: ${res['action_executed']}\n\nTeam FireCoders | AISeekho 2026';
    } else if (platform == 'Twitter') {
      return '🚨 ${res['scenario_label']}\n\n${res['insight']}\n\nAction: ${res['action_executed']}\n\n#AISeekho2026 #InsightFlowAI #Pakistan';
    } else if (platform == 'LinkedIn') {
      return 'InsightFlow AI Detection:\n\n${res['scenario_label']}\n\nInsight: ${res['insight']}\nImpact: ${res['impact']?['financial_display']}\nAction: ${res['action_executed']}\n\nTeam FireCoders | AISeekho 2026 🚀';
    }
    return '⚡ InsightFlow AI Alert\n${res['scenario_label']}\n${res['insight']}\nAction: ${res['action_executed']}';
  }

  Widget resultCard({required String title, required Color titleColor, required Color borderColor, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: borderColor, width: 4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: titleColor, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(content, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget impactMetric(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: GoogleFonts.inter(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
    ]);
  }

  Widget tableRow(String metric, String before, String after) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF334155), width: 0.5))),
      child: Row(children: [
        Expanded(child: Text(metric, style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 12))),
        Expanded(child: Text(before, textAlign: TextAlign.center, style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontSize: 12))),
        Expanded(child: Text(after, textAlign: TextAlign.center, style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget notifChip(String icon, String platform, String status, Color color) {
    return GestureDetector(
      onTap: () => showNotifDetail(platform),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(platform, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            Text(status, style: TextStyle(color: color, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }

  Widget legendRow(Color color, String label, String value) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11))),
      Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    ]);
  }
}
