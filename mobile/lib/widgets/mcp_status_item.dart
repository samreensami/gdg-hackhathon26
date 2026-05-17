import 'package:flutter/material.dart';

class McpStatusItem extends StatelessWidget {
  final String label;
  final bool connected;
  final Color? color;

  const McpStatusItem({super.key, required this.label, required this.connected, this.color});

  @override
  Widget build(BuildContext context) {
    final dotColor = color ?? const Color(0xFF10B981);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: dotColor.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)])),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white))),
          Text(connected ? "● Connected" : "● Inactive", style: TextStyle(color: dotColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
