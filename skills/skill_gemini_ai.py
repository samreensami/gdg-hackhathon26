def call_gemini_chat(message, history=[], system_prompt=None):
    try:
        from config_secrets import GEMINI_API_KEY
        import requests
        
        if not system_prompt:
            system_prompt = """You are InsightFlow AI Assistant for Pakistan. Help with business problems in simple Urdu/English."""
        
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
