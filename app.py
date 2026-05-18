from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import json

app = Flask(__name__)
CORS(app)

print("Routes registered:")
print("  /health - GET")
print("  /analyze - POST") 
print("  /news - GET")
print("  /chat - POST")

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        "status": "InsightFlow AI is live!",
        "version": "1.1",
        "team": "FireCoders",
        "endpoints": ["/analyze", "/health", "/news", "/chat"]
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "agents": 3,
        "scenarios": 5
    })

@app.route('/news', methods=['GET'])
def get_news():
    try:
        from config_secrets import NEWS_API_KEY
        import requests
        
        topic = request.args.get('topic', 'Pakistan business')
        
        url = "https://newsapi.org/v2/everything"
        params = {
            "q": topic,
            "language": "en",
            "sortBy": "publishedAt",
            "pageSize": 5,
            "apiKey": NEWS_API_KEY
        }
        
        response = requests.get(url, params=params, timeout=10)
        data = response.json()
        
        articles = []
        for a in data.get("articles", []):
            if a.get("title") and "[Removed]" not in str(a.get("title","")):
                articles.append({
                    "title": a["title"],
                    "source": a["source"]["name"],
                    "published": a["publishedAt"][:10]
                })
        
        return jsonify({
            "success": True,
            "articles": articles
        })
        
    except Exception as e:
        return jsonify({
            "success": True,
            "articles": [
                {
                    "title": "Pakistan supply chain faces challenges amid fuel prices",
                    "source": "Dawn News",
                    "published": "2026-05-18"
                },
                {
                    "title": "WAPDA announces load shedding for Punjab industries",
                    "source": "Geo News",
                    "published": "2026-05-18"
                },
                {
                    "title": "PKR exchange rate update - interbank market",
                    "source": "ARY News",
                    "published": "2026-05-18"
                }
            ]
        })

@app.route('/chat', methods=['POST'])
def chat():
    try:
        data = request.json
        message = data.get('message', '')
        province = data.get('province', 'all')
        history = data.get('history', [])
        
        province_context = {
            'sindh': 'Focus on Sindh: Karachi port, flooding, supply chain.',
            'punjab': 'Focus on Punjab: Lahore, Faisalabad, load shedding, exports.',
            'kpk': 'Focus on KPK: Peshawar, floods, agriculture.',
            'balochistan': 'Focus on Balochistan: Gwadar, CPEC, flooding.',
            'islamabad': 'Focus on Islamabad: Federal policy, PKR, finance.',
            'all': 'Cover all of Pakistan.'
        }
        
        system_prompt = f"""You are InsightFlow AI Assistant for Pakistan.
Team FireCoders | AISeekho 2026

Province context: {province_context.get(province, 'All Pakistan')}

IMPORTANT RULES:
- Always respond in ENGLISH only
- Keep response to 2-3 sentences maximum
- Be specific to Pakistan context
- Mention PKR for currency
- Suggest running a scenario at the end
- Do not use Urdu script"""

        from config_secrets import GEMINI_API_KEY
        import requests as req
        
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={GEMINI_API_KEY}"
        
        payload = {
            "contents": [{
                "parts": [{
                    "text": system_prompt + "\n\nUser: " + message
                }]
            }],
            "generationConfig": {
                "temperature": 0.7,
                "maxOutputTokens": 150
            }
        }
        
        response = req.post(url, json=payload, timeout=10)
        result = response.json()
        
        reply = result['candidates'][0]['content']['parts'][0]['text']
        
        return jsonify({
            "success": True,
            "reply": reply.strip()
        })
        
    except Exception as e:
        print(f"Chat error: {e}")
        return jsonify({
            "success": True,
            "reply": "I can help with Pakistan business challenges! Please select a scenario and run analysis for detailed insights."
        })

@app.route('/analyze', methods=['POST'])
def analyze():
    from agents.ingestion_agent import IngestionAgent
    from agents.analyst_agent import AnalystAgent  
    from agents.action_agent import ActionAgent
    
    try:
        data = request.json
        input_text = data.get('text', '')
        scenario_type = data.get('scenario_type', 'SUPPLY_CHAIN')
        
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
            "data": {
                "scenario_label": scenario_type,
                "urgency": "CRITICAL",
                "insight": "Simulation mode active",
                "impact": {
                    "financial_display": "PKR 2.3M",
                    "units_value": 340,
                    "severity_score": 8.5
                }
            }
        })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
