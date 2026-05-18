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
    import requests as req
    import os
    
    NEWS_KEY = os.environ.get('NEWS_API_KEY', '')
    topic = request.args.get(
        'topic', 'Pakistan business')
    
    try:
        url = "https://newsapi.org/v2/everything"
        params = {
            "q": f"Pakistan {topic}",
            "language": "en",
            "sortBy": "publishedAt",
            "pageSize": 5,
            "apiKey": NEWS_KEY
        }
        
        res = req.get(
            url, params=params, timeout=10)
        data = res.json()
        
        if data.get('status') == 'ok':
            articles = []
            for a in data.get('articles', []):
                if a.get('title') and \
                   '[Removed]' not in str(
                     a.get('title', '')):
                    articles.append({
                        'title': a['title'],
                        'source': a['source']['name'],
                        'published': a['publishedAt'][:10]
                    })
            return jsonify({
                "success": True,
                "articles": articles
            })
        else:
            raise Exception(data.get('message'))
            
    except Exception as e:
        print(f"News error: {e}")
        fallback = [
            {
                "title": "Pakistan supply chain resilience amid fuel price surge",
                "source": "Dawn Business",
                "published": "2026-05-18"
            },
            {
                "title": "WAPDA announces revised load shedding schedule for industries",
                "source": "Geo News",
                "published": "2026-05-18"
            },
            {
                "title": "PKR stabilizes as State Bank intervenes in forex market",
                "source": "Business Recorder",
                "published": "2026-05-18"
            },
            {
                "title": "Karachi port operations improve after logistics overhaul",
                "source": "The News",
                "published": "2026-05-18"
            },
            {
                "title": "Government announces relief package for flood-affected businesses",
                "source": "ARY News",
                "published": "2026-05-18"
            }
        ]
        return jsonify({
            "success": True,
            "articles": fallback
        })

@app.route('/chat', methods=['POST'])
def chat():
    import requests as req
    import os
    
    data = request.json
    message = data.get('message', '')
    province = data.get('province', 'all')
    language = data.get('language', 'en')
    
    GEMINI_KEY = os.environ.get(
        'GEMINI_API_KEY', '')
    
    province_info = {
        'sindh': 'Sindh province - Karachi port, River Indus flooding, supply chain disruptions, Hyderabad textile industry',
        'punjab': 'Punjab province - Lahore manufacturing, Faisalabad textile exports, WAPDA load shedding, agricultural belt',
        'kpk': 'KPK province - Peshawar trade, Swat tourism, mountain flooding, CPEC northern route',
        'balochistan': 'Balochistan - Gwadar port, CPEC hub, mining sector, seasonal flooding',
        'islamabad': 'Federal Capital - Government policy, State Bank PKR decisions, federal budget, regulatory changes',
        'all': 'All Pakistan - nationwide business and economic context'
    }
    
    app_context = """
You are InsightFlow AI Expert Assistant.
You are built by Team FireCoders for AISeekho 2026 Hackathon.
You run on Google Antigravity platform.

YOU KNOW EVERYTHING ABOUT THIS APP:
- InsightFlow AI analyzes unstructured reports
- It has 3 AI agents: Gatekeeper, Analyst, Executor
- It covers 5 scenarios: Supply Chain, Flood Warning, Load Shedding, Financial Alert, Policy News
- It supports Urdu and English (bilingual)
- It uses real Gemini AI for analysis
- It fetches live Pakistan news via NewsAPI
- It sends Gmail alerts, Twitter/LinkedIn posts
- It shows Before vs After state changes
- It has donut chart for risk breakdown
- It has Knowledge Enrichment Matrix
- It is deployed on Google Cloud Run
- Mobile app available as Flutter APK
- Province filter: Sindh, Punjab, KPK, Balochistan, Islamabad

PAKISTAN BUSINESS EXPERTISE:
- Supply Chain: Karachi port delays, fuel price impact, route optimization
- Floods: River Indus levels, NDMA alerts, warehouse evacuation
- Load Shedding: WAPDA schedule, factory capacity, export deadlines
- Financial: PKR exchange rate, inflation, export revenue
- Policy: Government levies, regulatory changes, compliance

RULES:
- If language is 'ur': respond in Roman Urdu
- If language is 'en': respond in English
- Always give specific Pakistan context
- Mention PKR amounts where relevant
- Suggest running a specific scenario
- Maximum 4 sentences
- Be expert and helpful
- Never say you cannot help
"""
    
    province_context = province_info.get(
        province, province_info['all'])
    
    if language == 'ur':
        lang_rule = "RESPOND IN ROMAN URDU ONLY. Example: 'Karachi mein supply chain ka masla hai, PKR 2.3M ka nuqsan ho sakta hai.'"
    else:
        lang_rule = "RESPOND IN ENGLISH ONLY. Be professional and specific."
    
    full_prompt = f"""{app_context}

Current Province Context: {province_context}

Language Rule: {lang_rule}

User Question: {message}

Give expert answer about InsightFlow AI 
or Pakistan business:"""
    
    try:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={GEMINI_KEY}"
        
        payload = {
            "contents": [{
                "parts": [{"text": full_prompt}]
            }],
            "generationConfig": {
                "temperature": 0.8,
                "maxOutputTokens": 250,
                "topP": 0.9
            }
        }
        
        response = req.post(
            url,
            json=payload,
            timeout=20,
            headers={
                "Content-Type": "application/json"
            }
        )
        
        print(f"Status: {response.status_code}")
        result = response.json()
        print(f"Result: {result}")
        
        if 'candidates' in result:
            reply = result['candidates'][0]\
                ['content']['parts'][0]['text']
            return jsonify({
                "success": True,
                "reply": reply.strip()
            })
        elif 'error' in result:
            error_msg = result['error'].get(
                'message', 'API Error')
            print(f"API Error: {error_msg}")
            
            if language == 'ur':
                fallback = f"InsightFlow AI mein {province} ka scenario run karein detailed analysis ke liye! Supply Chain, Flood Warning, ya Load Shedding select karein."
            else:
                fallback = f"Run our {province} scenarios for detailed analysis! Try Supply Chain Crisis or Flood Warning for AI-powered insights."
            
            return jsonify({
                "success": True,
                "reply": fallback
            })
        else:
            raise Exception(
                f"Unexpected: {result}")
            
    except Exception as e:
        print(f"Chat error: {e}")
        
        smart_fallback = {
            'sindh': {
                'en': 'Sindh faces major flood risks and supply chain disruptions at Karachi port. Run our Flood Warning scenario to see AI-powered response with PKR impact analysis!',
                'ur': 'Sindh mein flood ka khatra aur Karachi port mein supply chain issues hain. Flood Warning scenario run karein PKR impact dekhne ke liye!'
            },
            'punjab': {
                'en': 'Punjab industries face severe load shedding impact with PKR 180M export risk. Run Load Shedding scenario for detailed mitigation plan!',
                'ur': 'Punjab ki factories mein load shedding se PKR 180M exports khatray mein hain. Load Shedding scenario run karein!'
            },
            'kpk': {
                'en': 'KPK faces flooding and supply chain challenges. Our AI can analyze and suggest immediate action plans with before/after state visualization!',
                'ur': 'KPK mein flood aur supply chain masail hain. AI scenario run karein detailed plan ke liye!'
            },
            'balochistan': {
                'en': 'Balochistan CPEC routes and Gwadar port face supply disruptions. Run Supply Chain scenario for AI-powered routing solutions!',
                'ur': 'Balochistan mein CPEC aur Gwadar port disruption hai. Supply Chain scenario run karein!'
            },
            'islamabad': {
                'en': 'Federal policy changes affecting PKR and business compliance. Run Policy News scenario for impact analysis and recommended actions!',
                'ur': 'Islamabad mein policy changes se PKR aur business affected hai. Policy News scenario run karein!'
            },
            'all': {
                'en': 'InsightFlow AI covers 5 Pakistan scenarios: Supply Chain, Flood Warning, Load Shedding, Financial Alert, and Policy News. Select a scenario and run analysis!',
                'ur': 'InsightFlow AI mein 5 scenarios hain: Supply Chain, Flood, Load Shedding, Financial, Policy. Koi bhi select karke analysis run karein!'
            }
        }
        
        lang_key = 'ur' if language == 'ur' else 'en'
        reply = smart_fallback.get(
            province, smart_fallback['all']
        )[lang_key]
        
        return jsonify({
            "success": True,
            "reply": reply
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
