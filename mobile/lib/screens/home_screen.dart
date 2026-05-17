import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../main.dart';
import '../widgets/scenario_button.dart';
import '../widgets/mcp_status_item.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedScenario = "SUPPLY_CHAIN";
  String _timeString = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    if (!mounted) return;
    final String formattedTime = DateTime.now().toString().split(' ')[1].substring(0, 8);
    setState(() => _timeString = formattedTime);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    bool urdu = appState.language == 'ur';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("⚡ InsightFlow AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: [
                    Text(_timeString, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    const SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                      onPressed: () => appState.toggleLanguage(),
                      child: Text(urdu ? "🌐 EN" : "🌐 اردو", style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            const Text("Autonomous Content-to-Action Agent", style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text("AISeekho 2026 | Powered by Google Antigravity", style: TextStyle(color: Color(0xFF10B981), fontSize: 9)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. INPUT SOURCE CARD
            _buildCard(
              title: urdu ? "ان پٹ ذریعہ" : "INPUT SOURCE",
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF334155),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.touch_app, 
                          color: Color(0xFF3B82F6), 
                          size: 32),
                        const SizedBox(height: 8),
                        Text(
                          urdu ? "نیچے سے ایک منظر نامہ منتخب کریں" : "Select a scenario below",
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. SCENARIO BUTTONS
            _buildCard(
              title: urdu ? "سنیریو منتخب کریں" : "SELECT SCENARIO",
              child: Column(
                children: [
                  _scenarioRow("🏭", urdu ? "سپلائی چین بحران" : "Supply Chain Crisis", "CRITICAL", const Color(0xFFEF4444), "SUPPLY_CHAIN"),
                  _scenarioRow("🌊", urdu ? "سیلاب وارننگ" : "Flood Warning", "EMERGENCY", const Color(0xFFEF4444), "FLOOD"),
                  _scenarioRow("⚡", urdu ? "لوڈ شیڈنگ" : "Load Shedding", "HIGH", const Color(0xFFF59E0B), "LOAD_SHEDDING"),
                  _scenarioRow("💰", urdu ? "مالی الرٹ" : "Financial Alert", "HIGH", const Color(0xFFF59E0B), "FINANCIAL"),
                  _scenarioRow("📰", urdu ? "پالیسی خبریں" : "Policy News", "MEDIUM", const Color(0xFF3B82F6), "POLICY"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. RUN ANALYSIS BUTTON
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 15, spreadRadius: 0)],
                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnalysisScreen(scenarioType: selectedScenario))),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.bolt, color: Colors.white),
                label: Text(urdu ? "تجزیہ چلائیں" : "RUN ANALYSIS", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 16),

            // 4. MCP STATUS
            _buildCard(
              title: urdu ? "کنکشن اسٹیٹس" : "MCP STATUS",
              child: Column(
                children: const [
                  McpStatusItem(label: "Gmail API", connected: true),
                  McpStatusItem(label: "GitHub Connector", connected: true),
                  McpStatusItem(label: "Google Drive Store", connected: true),
                  McpStatusItem(label: "Sequential Thinking", connected: true, color: Color(0xFF3B82F6)),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _scenarioRow(String icon, String title, String badge, Color color, String type) {
    bool isSelected = selectedScenario == type;
    return ScenarioButton(
      icon: icon,
      title: title,
      badge: badge,
      badgeColor: color,
      scenarioType: type,
      isSelected: isSelected,
      onTap: () => setState(() => selectedScenario = type),
    );
  }
}
