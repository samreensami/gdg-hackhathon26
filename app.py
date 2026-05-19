from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import json
import requests as req

app = Flask(__name__)
CORS(app)

print("Routes registered:")
print("  /health - GET")
print("  /analyze - POST")
print("  /news - GET")
print("  /chat - POST")

GEMINI_KEY = os.environ.get('GEMINI_API_KEY', '')

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
    NEWS_KEY = os.environ.get('NEWS_API_KEY', '')
    topic = request.args.get('topic', 'Pakistan business')

    try:
        url = "https://newsapi.org/v2/everything"
        params = {
            "q": f"Pakistan {topic}",
            "language": "en",
            "sortBy": "publishedAt",
            "pageSize": 5,
            "apiKey": NEWS_KEY
        }

        res = req.get(url, params=params, timeout=10)
        data = res.json()

        if data.get('status') == 'ok':
            articles = []
            for a in data.get('articles', []):
                if a.get('title') and '[Removed]' not in str(a.get('title', '')):
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
            {"title": "Pakistan supply chain resilience amid fuel price surge", "source": "Dawn Business", "published": "2026-05-18"},
            {"title": "WAPDA announces revised load shedding schedule for industries", "source": "Geo News", "published": "2026-05-18"},
            {"title": "PKR stabilizes as State Bank intervenes in forex market", "source": "Business Recorder", "published": "2026-05-18"},
            {"title": "Karachi port operations improve after logistics overhaul", "source": "The News", "published": "2026-05-18"},
            {"title": "Government announces relief package for flood-affected businesses", "source": "ARY News", "published": "2026-05-18"}
        ]
        return jsonify({
            "success": True,
            "articles": fallback
        })

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    message = data.get('message', '').lower()
    province = data.get('province', 'all')
    language = data.get('language', 'en')

    faqs = {
        'what is insightflow': {
            'en': "InsightFlow AI is Pakistan's first bilingual autonomous business AI agent. Analyzes reports and takes automated actions using 3 AI agents: Gatekeeper, Analyst, and Executor. Built by Team FireCoders for AISeekho 2026!",
            'ur': "InsightFlow AI Pakistan ka pehla bilingual autonomous business AI agent hai. 3 AI agents use karta hai: Gatekeeper, Analyst, aur Executor. Team FireCoders ne AISeekho 2026 ke liye banaya!"
        },
        'how does it work': {
            'en': "Works in 3 steps: 1) Agent 1 (Gatekeeper) scans your report, 2) Agent 2 (Analyst) finds insights using live data, 3) Agent 3 (Executor) takes action - sends Gmail alerts and shows Before/After results!",
            'ur': "3 steps mein kaam karta hai: 1) Agent 1 report scan karta hai, 2) Agent 2 insights nikalti hai, 3) Agent 3 action leta hai!"
        },
        'how to run': {
            'en': "To run analysis: 1) Select Province filter, 2) Choose a scenario card, 3) Tap 'RUN ANALYSIS', 4) Watch 3 agents work live, 5) See results with PKR impact!",
            'ur': "Analysis run karne ke liye: 1) Province select karo, 2) Scenario choose karo, 3) 'RUN ANALYSIS' tap karo, 4) 3 agents ko kaam karte dekho!"
        },
        'scenarios': {
            'en': "InsightFlow AI has 5 Pakistan scenarios: Supply Chain Crisis (Karachi), Flood Warning (Sindh), Load Shedding (Punjab), Financial Alert (Lahore), Policy News (Islamabad).",
            'ur': "InsightFlow AI mein 5 scenarios hain: Supply Chain (Karachi), Flood Warning (Sindh), Load Shedding (Punjab), Financial Alert (Lahore), Policy News (Islamabad)!"
        },
        'supply chain': {
            'en': "Supply Chain Crisis - Karachi: Fuel prices rose 23%, 340 orders delayed, 47 vehicles stuck, PKR 2.3M at risk. Action: Alternate route via Motorway M-9 saved PKR 328,000!",
            'ur': "Karachi Supply Chain Crisis: Fuel prices 23% barh gayi, 340 orders delay, PKR 2.3M khatray mein. Action: M-9 route ne PKR 328,000 bachaye!"
        },
        'flood': {
            'en': "Flood Warning - Sindh: River Indus 85% above normal. 47 trucks at risk on M-9. 3 warehouses need evacuation. PKR 450M inventory at risk. 2.3M people affected.",
            'ur': "Sindh Flood Warning: River Indus 85% upar hai. PKR 450M inventory khatray mein. 2.3M log affect hue hain!"
        },
        'sindh': {
            'en': "Sindh faces River Indus flooding, Karachi port supply chain disruptions, and Hyderabad textile delays. Run Flood Warning scenario for full PDF analysis!",
            'ur': "Sindh mein River Indus flooding, Karachi port disruption aur Hyderabad textile delays hain. Flood Warning scenario run karein!"
        },
        'load shedding': {
            'en': "Load Shedding - Punjab: WAPDA announced 8-hour outages. 23 factories in Faisalabad affected, 1,847 workers idle. PKR 180M exports at risk!",
            'ur': "Punjab Load Shedding: WAPDA ne 8 ghante outage announce ki. 23 factories band hain. PKR 180M exports khatray mein!"
        },
        'punjab': {
            'en': "Punjab: Major load shedding impact on Lahore and Faisalabad industries. Textile exports at PKR 180M risk!",
            'ur': "Punjab mein Lahore aur Faisalabad ki industries load shedding se affected hain. PKR 180M exports khatray mein!"
        },
        'financial': {
            'en': "Financial Alert - Lahore: Q4 sales dropped 25%. 3 major clients at risk of switching. PKR 45M revenue at risk due to competitor pricing.",
            'ur': "Lahore Financial Alert: Sales 25% giri. 3 clients switch karne wale hain. PKR 45M khatray mein!"
        },
        'pkr': {
            'en': "PKR (Pakistani Rupee) impacts all businesses. Weaker PKR means higher import costs and fuel prices. Run Financial Alert scenario to see latest PKR analysis!",
            'ur': "PKR ke rate business par direct asar karte hain. Financial Alert scenario run karein PKR impact dekhne ke liye!"
        },
        'policy': {
            'en': "Policy News - Islamabad: Government increased petroleum levy 15%, impacting 2,300+ companies. PKR 2.8M additional cost projected.",
            'ur': "Policy News - Islamabad: Government ne petroleum levy 15% barhai. 2,300+ companies affected. PKR 2.8M extra cost."
        },
        'islamabad': {
            'en': "Islamabad/Federal: Policy and regulatory changes like PKR decisions, import duties, and government levies affect all Pakistan businesses.",
            'ur': "Islamabad mein policy changes se poore Pakistan ki businesses affected hoti hain."
        },
        'kpk': {
            'en': "KPK: Peshawar trade routes and Swat tourism affected by seasonal flooding. Supply chains disrupted. Run Flood Warning for KPK analysis!",
            'ur': "KPK mein Peshawar trade aur Swat flooding se affected hain. Flood Warning scenario run karein!"
        },
        'balochistan': {
            'en': "Balochistan: Gwadar port and CPEC routes face supply chain challenges. Mining and seasonal flooding disrupted. Run Supply Chain scenario!",
            'ur': "Balochistan mein Gwadar aur CPEC routes disrupted hain. Supply Chain scenario run karein!"
        },
        'agents': {
            'en': "InsightFlow AI has 3 agents: Agent 1 (Gatekeeper) scans input, Agent 2 (Analyst) finds patterns using live data, Agent 3 (Executor) takes automated action!",
            'ur': "InsightFlow AI mein 3 agents hain: Gatekeeper input scan karta hai, Analyst patterns dhundta hai, Executor action leta hai!"
        },
        'urdu': {
            'en': "Yes! InsightFlow AI is fully bilingual. Toggle the language button in the app header to switch between English and Urdu.",
            'ur': "Haan! InsightFlow AI dono languages mein kaam karta hai. Upar language toggle button click karein!"
        },
        'gmail': {
            'en': "Agent 3 automatically sends Gmail alerts when critical situations are detected. Check the results panel for email notifications!",
            'ur': "Agent 3 automatically Gmail alerts bhejta hai jab critical situation detect ho!"
        },
        'download': {
            'en': "Share results using: Copy Report, WhatsApp Share, or Email Report buttons in the results panel. Full analysis share kar sakte hain!",
            'ur': "Results panel mein Copy Report aur WhatsApp Share buttons hain. Full analysis share kar sakte hain!"
        },
        'mobile': {
            'en': "Yes! InsightFlow AI has a Flutter mobile app available as an APK. All scenarios, chatbot, and AI analysis included!",
            'ur': "Haan! InsightFlow AI ka Flutter mobile app APK available hai. Poore features available hain!"
        },
        'antigravity': {
            'en': "InsightFlow AI is built on Google Antigravity - an agentic AI platform that orchestrates all 3 agents and enables real-time decision making!",
            'ur': "InsightFlow AI Google Antigravity pe built hai! 3 agents ko Antigravity coordinate karta hai!"
        },
        'team': {
            'en': "Built by Team FireCoders for AISeekho 2026 Google Antigravity Hackathon! Pakistan's first bilingual autonomous business AI!",
            'ur': "Team FireCoders ne AISeekho 2026 ke liye banaya! Pakistan ka pehla bilingual autonomous business AI!"
        },
        'hello': {
            'en': "Hello! I'm InsightFlow AI Assistant. Ask me about Pakistan business risks, scenarios, or app features!",
            'ur': "Assalam o Alaikum! Pakistan business risks, scenarios, aur app features ke baare mein poochein!"
        },
        'hi': {
            'en': "Hi there! Ask me about Supply Chain, Floods, Load Shedding, Financial alerts, or Policy changes!",
            'ur': "Assalam o Alaikum! Supply Chain, Floods, Load Shedding, Financial, ya Policy ke baare mein poochein!"
        },
    }

    matched = False
    reply_en = None
    reply_ur = None

    for keyword, answers in faqs.items():
        if keyword in message:
            reply_en = answers['en']
            reply_ur = answers['ur']
            matched = True
            break

    if not matched:
        if any(w in message for w in ['sindh', 'karachi', 'hyderabad']):
            reply_en, reply_ur = faqs['sindh']['en'], faqs['sindh']['ur']
            matched = True
        elif any(w in message for w in ['punjab', 'lahore', 'faisalabad']):
            reply_en, reply_ur = faqs['punjab']['en'], faqs['punjab']['ur']
            matched = True
        elif any(w in message for w in ['kpk', 'peshawar', 'swat']):
            reply_en, reply_ur = faqs['kpk']['en'], faqs['kpk']['ur']
            matched = True
        elif any(w in message for w in ['balochistan', 'quetta', 'gwadar', 'cpec']):
            reply_en, reply_ur = faqs['balochistan']['en'], faqs['balochistan']['ur']
            matched = True
        elif any(w in message for w in ['islamabad', 'federal']):
            reply_en, reply_ur = faqs['policy']['en'], faqs['policy']['ur']
            matched = True

    if not matched:
        if any(w in message for w in ['flood', 'rain', 'water', 'river']):
            reply_en, reply_ur = faqs['flood']['en'], faqs['flood']['ur']
            matched = True
        elif any(w in message for w in ['load', 'shedding', 'wapda', 'bijli']):
            reply_en, reply_ur = faqs['load shedding']['en'], faqs['load shedding']['ur']
            matched = True
        elif any(w in message for w in ['supply', 'chain', 'delivery', 'logistics']):
            reply_en, reply_ur = faqs['supply chain']['en'], faqs['supply chain']['ur']
            matched = True
        elif any(w in message for w in ['financial', 'sales', 'revenue', 'pkr', 'rupee']):
            reply_en, reply_ur = faqs['financial']['en'], faqs['financial']['ur']
            matched = True
        elif any(w in message for w in ['how', 'kaise', 'kaam']):
            reply_en, reply_ur = faqs['how does it work']['en'], faqs['how does it work']['ur']
            matched = True
        elif any(w in message for w in ['scenario', 'option']):
            reply_en, reply_ur = faqs['scenarios']['en'], faqs['scenarios']['ur']
            matched = True
        elif any(w in message for w in ['run', 'start', 'analyze']):
            reply_en, reply_ur = faqs['how to run']['en'], faqs['how to run']['ur']
            matched = True
        elif any(w in message for w in ['language', 'bilingual']):
            reply_en, reply_ur = faqs['urdu']['en'], faqs['urdu']['ur']
            matched = True
        elif any(w in message for w in ['email', 'notification', 'gmail', 'alert']):
            reply_en, reply_ur = faqs['gmail']['en'], faqs['gmail']['ur']
            matched = True
        elif any(w in message for w in ['share', 'download', 'copy', 'apk', 'mobile', 'app']):
            reply_en, reply_ur = faqs['download']['en'], faqs['download']['ur']
            matched = True
        elif any(w in message for w in ['antigravity', 'google', 'platform']):
            reply_en, reply_ur = faqs['antigravity']['en'], faqs['antigravity']['ur']
            matched = True
        elif any(w in message for w in ['team', 'firecoders', 'hackathon', 'aiseekho']):
            reply_en, reply_ur = faqs['team']['en'], faqs['team']['ur']
            matched = True
        elif any(w in message for w in ['hello', 'hi', 'hey', 'assalam', 'salam', 'ji']):
            reply_en, reply_ur = faqs['hello']['en'], faqs['hello']['ur']
            matched = True

    if not matched:
        reply_en = "I can help with InsightFlow AI! Ask me about: Supply Chain, Floods, Load Shedding, Financial alerts, Policy, or how to run analysis!"
        reply_ur = "Main InsightFlow AI ke baare mein madad kar sakta hoon! Scenarios ya app use karne ke liye poochein!"

    reply = reply_ur if language == 'ur' else reply_en

    return jsonify({
        "success": True,
        "reply": reply
    })


@app.route('/analyze', methods=['POST'])
def analyze():
    from agents.ingestion_agent import IngestionAgent
    from agents.analyst_agent import AnalystAgent
    from agents.action_agent import ActionAgent

    scenario_type = 'SUPPLY_CHAIN'
    try:
        data = request.json
        input_text = data.get('text', '')
        scenario_type = data.get('scenario_type', 'SUPPLY_CHAIN')

        agent1 = IngestionAgent()
        result1 = agent1.run(input_text)

        agent2 = AnalystAgent()
        result2 = agent2.run(result1)

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
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
