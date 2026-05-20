import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Cloud link hata kar aapke local computer ka IP port 5000 ke sath set kar diya hai
  static const String baseUrl = 'http://192.168.100.4:5000';
  
  static Future<Map<String, dynamic>> analyze(String type, String lang) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': 'Scenario trigger for $type',
          'scenario_type': type,
          'language': lang,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return getDemoData(type, lang);
    } catch (e) {
      return getDemoData(type, lang);
    }
  }
  
  static Map<String, dynamic> getDemoData(String scenarioType, [String lang = 'en']) {
    if (scenarioType == 'FLOOD') {
      return {
        "scenario_label": "🌊 FLOOD WARNING ANALYSIS",
        "urgency": "EMERGENCY",
        "urgency_score": 9.8,
        "agent1_logs": [
          "🔍 Scanning: RED ALERT found",
          "📍 Location: Sindh detected",
          "⚠️ River Indus 85% above normal",
          "⏰ Time window: 6 hours",
          "⚡ Urgency: EMERGENCY (9.8/10)"
        ],
        "agent2_logs": [
          "🧠 2022 flood match: 87%",
          "💰 Financial risk: PKR 450M",
          "👥 People affected: 2.3M",
          "🎯 Action: Immediate evacuation",
          "📊 Impact: CRITICAL level"
        ],
        "agent3_logs": [
          "⚡ Emergency Protocol Alpha",
          "🚛 47 trucks rerouted N-55",
          "🏭 3 warehouses evacuated",
          "📧 NDMA alert dispatched",
          "✅ 6hr window secured"
        ],
        "insight": "River levels critical, 6 hour window before flooding",
        "impact": {
          "financial_display": "PKR 450M",
          "units_label": "People Affected",
          "units_value": 2300000,
          "severity_score": 9.8,
        },
        "action_executed": "Reroute trucks + evacuate warehouses via N-55",
        "before_after": [
          {"metric": "Truck Status", "before": "47 on M-9", "after": "Rerouted N-55"},
          {"metric": "Warehouse", "before": "3 at risk", "after": "Evacuated"},
          {"metric": "ETA", "before": "Flooded 6hr", "after": "Secured"},
          {"metric": "Loss", "before": "PKR 450M", "after": "PKR 70M saved"},
        ],
        "enrichment": {"historical": 87, "infra": 80, "pop": 76}
      };
    } else if (scenarioType == 'LOAD_SHEDDING') {
      return {
        "scenario_label": "⚡ LOAD SHEDDING ANALYSIS",
        "urgency": "HIGH",
        "urgency_score": 8.2,
        "agent1_logs": [
          "🔍 Scanning: WAPDA alert found",
          "📍 Location: Faisalabad detected",
          "⚠️ 8 hours daily outage",
          "🏭 23 factories affected",
          "⚡ Urgency: HIGH (8.2/10)"
        ],
        "agent2_logs": [
          "🧠 2023 grid failure match: 91%",
          "💰 Export risk: PKR 180M",
          "👷 Workers idle: 1,847",
          "🎯 Action: Night shift activation",
          "📊 Penalty risk: PKR 45M"
        ],
        "agent3_logs": [
          "⚡ Night shift protocol activated",
          "🏭 23 factories rescheduled",
          "📧 Client notifications sent",
          "💡 Generator fuel ordered",
          "✅ Deadlines secured"
        ],
        "insight": "72hr outage threatening PKR 180M export deadlines",
        "impact": {
          "financial_display": "PKR 180M",
          "units_label": "Factories Affected",
          "units_value": 23,
          "severity_score": 8.2,
        },
        "action_executed": "Activate night shifts + notify international clients",
        "before_after": [
          {"metric": "Production", "before": "40% capacity", "after": "85% capacity"},
          {"metric": "Deadlines", "before": "3 at risk", "after": "All secured"},
          {"metric": "Workers", "before": "1847 idle", "after": "Night shift active"},
          {"metric": "Penalty", "before": "PKR 45M risk", "after": "Avoided"},
        ],
        "enrichment": {"historical": 91, "infra": 65, "pop": 42}
      };
    } else if (scenarioType == 'FINANCIAL') {
      return {
        "scenario_label": "💰 FINANCIAL ALERT ANALYSIS",
        "urgency": "HIGH",
        "urgency_score": 7.5,
        "agent1_logs": [
          "🔍 Scanning: Sales decline found",
          "📍 Location: Lahore region",
          "📉 25% drop detected in Q4",
          "👥 3 major clients at risk",
          "⚡ Urgency: HIGH (7.5/10)"
        ],
        "agent2_logs": [
          "🧠 Q2 2023 pattern match: 83%",
          "💰 Revenue at risk: PKR 45M",
          "📊 Market share declining",
          "🎯 Action: Discount campaign",
          "📊 Churn risk: HIGH"
        ],
        "agent3_logs": [
          "⚡ Campaign protocol activated",
          "💌 Client retention emails sent",
          "💰 15% discount approved",
          "📊 Sales team notified",
          "✅ Recovery plan active"
        ],
        "insight": "Competitor pricing causing 25% Lahore sales decline",
        "impact": {
          "financial_display": "PKR 45M",
          "units_label": "Clients at Risk",
          "units_value": 3,
          "severity_score": 7.5,
        },
        "action_executed": "Launch regional discount campaign + client retention",
        "before_after": [
          {"metric": "Sales", "before": "Down 25%", "after": "Recovery started"},
          {"metric": "Clients", "before": "3 leaving", "after": "Retained"},
          {"metric": "Discount", "before": "None", "after": "15% offered"},
          {"metric": "Revenue", "before": "PKR 45M risk", "after": "PKR 32M secured"},
        ],
        "enrichment": {"historical": 83, "infra": 90, "pop": 55}
      };
    } else if (scenarioType == 'POLICY') {
      return {
        "scenario_label": "📰 POLICY NEWS ANALYSIS",
        "urgency": "MEDIUM",
        "urgency_score": 6.5,
        "agent1_logs": [
          "🔍 Scanning: Policy update found",
          "📍 Sector: Transport industry",
          "⚠️ Petroleum levy +15%",
          "🏢 2300+ companies affected",
          "⚡ Urgency: MEDIUM (6.5/10)"
        ],
        "agent2_logs": [
          "🧠 2022 levy shock match: 76%",
          "💰 Cost increase: PKR 2.8M",
          "🚛 Delivery pricing outdated",
          "🎯 Action: Update pricing",
          "📊 Compliance deadline: 30 days"
        ],
        "agent3_logs": [
          "⚡ Pricing update initiated",
          "📊 New rates calculated",
          "📧 Customer notification drafted",
          "💼 Compliance team alerted",
          "✅ Policy compliance secured"
        ],
        "insight": "Petroleum levy increase requires immediate pricing update",
        "impact": {
          "financial_display": "PKR 2.8M",
          "units_label": "Companies Affected",
          "units_value": 2300,
          "severity_score": 6.5,
        },
        "action_executed": "Update delivery pricing + notify customers",
        "before_after": [
          {"metric": "Pricing", "before": "Old rates", "after": "Updated +12%"},
          {"metric": "Compliance", "before": "Non-compliant", "after": "Compliant"},
          {"metric": "Customers", "before": "Not notified", "after": "SMS sent"},
          {"metric": "Cost", "before": "PKR 2.8M loss", "after": "Recovered"},
        ],
        "enrichment": {"historical": 76, "infra": 85, "pop": 62}
      };
    } else {
      // SUPPLY_CHAIN default
      return {
        "scenario_label": "🏭 SUPPLY CHAIN ANALYSIS",
        "urgency": "CRITICAL",
        "urgency_score": 9.5,
        "agent1_logs": [
          "🔍 Scanning: Disruption found",
          "📍 Location: Karachi South",
          "⚠️ Fuel prices +23%",
          "🚛 340 orders delayed",
          "⚡ Urgency: CRITICAL (9.5/10)"
        ],
        "agent2_logs": [
          "🧠 Oct 2023 match: 79%",
          "💰 Revenue risk: PKR 2.3M",
          "📦 340 orders affected",
          "🎯 Action: Route M-9",
          "📊 89 premium customers"
        ],
        "agent3_logs": [
          "⚡ Route M-9 activated",
          "🚛 47 vehicles rerouted",
          "📧 Gmail alert drafted",
          "🐦 Twitter post created",
          "✅ PKR 328K saved"
        ],
        "insight": "Fuel surge causing cascade delay in Karachi South",
        "impact": {
          "financial_display": "PKR 2.3M",
          "units_label": "Orders Affected",
          "units_value": 340,
          "severity_score": 9.5,
        },
        "action_executed": "Activate alternate route via Motorway M-9",
        "before_after": [
          {"metric": "Route", "before": "Old highway", "after": "M-9 active"},
          {"metric": "Delays", "before": "47 vehicles", "after": "0 vehicles"},
          {"metric": "ETA", "before": "72 hours", "after": "24 hours"},
          {"metric": "Savings", "before": "—", "after": "PKR 328,000"},
        ],
        "enrichment": {"historical": 92, "infra": 85, "pop": 64}
      };
    }
  }
}