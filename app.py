from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import os
from agents.ingestion_agent import IngestionAgent
from agents.analyst_agent import AnalystAgent  
from agents.action_agent import ActionAgent

app = Flask(__name__)
CORS(app)

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        "status": "InsightFlow AI is live!",
        "version": "1.0",
        "powered_by": "Google Antigravity + Gemini AI",
        "endpoints": ["/analyze", "/health"]
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "agents": 3,
        "scenarios": 5
    })

@app.route('/analyze', methods=['POST'])
def analyze():
    try:
        data = request.json
        input_text = data.get('text', '')
        scenario_type = data.get('scenario_type', 'SUPPLY_CHAIN')
        language = data.get('language', 'en')
        
        agent1 = IngestionAgent()
        result1 = agent1.run(input_text)
        
        agent2 = AnalystAgent()
        result2 = agent2.run(result1, scenario_type)
        
        agent3 = ActionAgent()
        result3 = agent3.run(result2)
        
        return jsonify({
            "success": True,
            "data": result3
        })
        
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e),
            "data": get_demo_data(scenario_type)
        })

def get_demo_data(scenario_type):
    return {
        "scenario_label": scenario_type,
        "urgency": "CRITICAL",
        "insight": "Demo mode active",
        "impact": {
            "financial_display": "PKR 2.3M",
            "units_value": 340,
            "severity_score": 8.5
        }
    }

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
