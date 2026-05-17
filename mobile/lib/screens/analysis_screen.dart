import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../main.dart';
import '../widgets/agent_card.dart';
import '../services/api_service.dart';
import 'results_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final String scenarioType;
  const AnalysisScreen({super.key, required this.scenarioType});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  double progress = 0.0;
  List<String> agentStatus = ["IDLE", "IDLE", "IDLE"];
  List<List<String>> agentLogs = [[], [], []];
  late Timer _timer;
  Map<String, dynamic>? analysisResult;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  void _startAnalysis() async {
    final lang = Provider.of<AppState>(context, listen: false).language;
    analysisResult = ApiService.getDemoData(widget.scenarioType, lang);

    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (mounted) setState(() => progress = (progress + 0.01).clamp(0, 1));
    });

    // Agent 1
    setState(() => agentStatus[0] = "PROCESSING");
    await _typeLogs(0);
    setState(() => agentStatus[0] = "COMPLETE");

    // Agent 2
    setState(() => agentStatus[1] = "PROCESSING");
    await _typeLogs(1);
    setState(() => agentStatus[1] = "COMPLETE");

    // Agent 3
    setState(() => agentStatus[2] = "PROCESSING");
    await _typeLogs(2);
    setState(() => agentStatus[2] = "COMPLETE");

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultsScreen(result: analysisResult!, scenarioType: widget.scenarioType)));
  }

  Future<void> _typeLogs(int idx) async {
    keySuffix() => idx == 0 ? 'agent1_logs' : (idx == 1 ? 'agent2_logs' : 'agent3_logs');
    final logs = analysisResult![keySuffix()] as List<String>;
    for (var log in logs) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) setState(() => agentLogs[idx].add("> ${DateTime.now().toString().split(' ')[1].substring(0, 8)} $log"));
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF0F172A), elevation: 0, title: const Text("Live Agent Pipeline", style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: const Color(0xFF1E293B), valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6))),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AgentCard(name: "AGENT 1: GATEKEEPER", icon: Icons.search, status: agentStatus[0], logs: agentLogs[0]),
                  const Icon(Icons.arrow_downward, color: Color(0xFF334155)),
                  AgentCard(name: "AGENT 2: ANALYST", icon: Icons.psychology, status: agentStatus[1], logs: agentLogs[1]),
                  const Icon(Icons.arrow_downward, color: Color(0xFF334155)),
                  AgentCard(name: "AGENT 3: EXECUTOR", icon: Icons.bolt, status: agentStatus[2], logs: agentLogs[2]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
