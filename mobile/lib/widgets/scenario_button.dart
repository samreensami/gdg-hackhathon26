import 'package:flutter/material.dart';

class ScenarioButton extends StatelessWidget {
  final String icon;
  final String title;
  final String badge;
  final Color badgeColor;
  final String scenarioType;
  final bool isSelected;
  final VoidCallback onTap;

  const ScenarioButton({super.key, required this.icon, required this.title, required this.badge, required this.badgeColor, required this.scenarioType, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.05) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF334155), width: 1),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.2), blurRadius: 8)] : [],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF94A3B8), fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: badgeColor.withOpacity(0.3))),
              child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
