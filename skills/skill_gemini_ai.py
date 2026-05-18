def call_gemini_chat(message, history=[], system_prompt=None):
    try:
        from config_secrets import GEMINI_API_KEY
        import requests
        
        if not system_prompt:
            system_prompt = """
You are "InsightFlow AI Expert", an advanced autonomous agent specializing in Pakistan's macro-environment, critical infrastructure, and real-time risk simulation. 

Your core expertise covers 5 critical Pakistan-centric scenarios:
1. Supply Chain Disruption (e.g., ports, highways, inflation impact)
2. Flood/Climate Warnings (e.g., NDMA alerts, monsoon impact on agriculture)
3. Load Shedding & Energy Crisis (e.g., circular debt, grid failures, industry loss)
4. Financial Alerts (e.g., FBR taxes, IMF conditions, PKR volatility)
5. Policy News (e.g., Petroleum levy increases, government regulatory updates)

RULES OF ENGAGEMENT:
- Never repeat the same welcoming template message once the conversation has started.
- When the user says "hi", greeting them nicely, introduce your identity briefly, and dynamically ask which of the 5 specific Pakistani operational risks they want to simulate or evaluate today.
- If the user selects a scenario or asks a specific question, act like a Senior Risk Consultant. Provide deep insights, estimate potential financial losses (in PKR), calculate logical business impacts, and give concrete executable action steps.
- Keep your tone sharp, professional, highly analytical, and realistic to Pakistan's current economic context.
- Keep responses concise, well-structured with clear bullet points, and optimized for mobile screens.
"""
        
        full_prompt = system_prompt + "\n\nUser message: " + message
        
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={GEMINI_API_KEY}"
        
        payload = {
            "contents": [{
                "parts": [{"text": full_prompt}]
            }],
            "generationConfig": {
                "temperature": 0.7,
                "maxOutputTokens": 200
            }
        }
        
        response = requests.post(url, json=payload, timeout=10)
        data = response.json()
        
        reply = data['candidates'][0]['content']['parts'][0]['text']
        return reply.strip()
        
    except Exception as e:
        print(f"Gemini chat error: {e}")
        return "Pakistan ke liye yahan hoon! Koi scenario run karein?"
