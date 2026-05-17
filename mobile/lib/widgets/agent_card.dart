import 'package:flutter/material.dart';

class AgentCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final String status;
  final List<String> logs;

  const AgentCard({super.key, required this.name, required this.icon, required this.status, required this.logs});

  @override
  Widget build(BuildContext context) {
    bool isProcessing = status == "PROCESSING";
    bool isComplete = status == "COMPLETE";
    Color borderColor = isComplete ? const Color(0xFF10B981) : (isProcessing ? const Color(0xFF3B82F6) : const Color(0xFF334155));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isProcessing ? 2 : 1),
        boxShadow: isProcessing ? [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 10, spreadRadius: 2)] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: borderColor, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: borderColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(status, style: TextStyle(color: borderColor, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          if (logs.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: logs.map((l) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(l, style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF10B981), fontSize: 10)))).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
