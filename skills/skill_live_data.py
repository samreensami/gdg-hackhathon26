import requests

def fetch_pakistan_news(topic="Pakistan business"):
    try:
        from config_secrets import NEWS_API_KEY
        import requests
        
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
        
        if data.get('status') != 'ok':
            return get_fallback_news()
            
        articles = []
        for a in data.get("articles", []):
            if a.get("title") and "[Removed]" not in a.get("title",""):
                articles.append({
                    "title": a["title"],
                    "source": a["source"]["name"],
                    "published": a["publishedAt"][:10],
                    "url": a.get("url", "")
                })
        
        print(f"📰 News fetched: {len(articles)}")
        return articles
        
    except Exception as e:
        print(f"⚠️ News error: {e}")
        return get_fallback_news()

def get_fallback_news():
    return [
        {
            "title": "Pakistan supply chain faces fuel price pressure",
            "source": "Dawn News",
            "published": "2026-05-18",
            "url": ""
        },
        {
            "title": "WAPDA announces load shedding schedule for Punjab",
            "source": "Geo News", 
            "published": "2026-05-18",
            "url": ""
        },
        {
            "title": "PKR strengthens against USD in interbank market",
            "source": "ARY News",
            "published": "2026-05-18",
            "url": ""
        },
        {
            "title": "Karachi port operations resume after disruption",
            "source": "Business Recorder",
            "published": "2026-05-18",
            "url": ""
        },
        {
            "title": "Government announces new policy for logistics sector",
            "source": "The News",
            "published": "2026-05-18",
            "url": ""
        }
    ]

def fetch_pakistan_weather(city="Karachi"):
    try:
        url = f"https://wttr.in/{city}?format=j1"
        r = requests.get(url, timeout=5)
        data = r.json()
        temp = data['current_condition'][0]['temp_C']
        humidity = data['current_condition'][0]['humidity']
        desc = data['current_condition'][0]['weatherDesc'][0]['value']
        print(f"🌤️ Weather: {city} {temp}°C")
        return {
            "city": city,
            "temperature": f"{temp}°C",
            "condition": desc,
            "humidity": f"{humidity}%",
            "flood_risk": "HIGH" if int(humidity) > 75 else "LOW"
        }
    except Exception as e:
        print(f"⚠️ Weather fallback: {e}")
        return {"city": city, "temperature": "32°C", "condition": "Clear", "flood_risk": "LOW"}

def fetch_pkr_rate():
    try:
        url = "https://api.exchangerate-api.com/v4/latest/USD"
        r = requests.get(url, timeout=5)
        data = r.json()
        pkr = round(data["rates"]["PKR"], 2)
        print(f"💰 PKR Rate: {pkr}")
        return {"usd_to_pkr": pkr, "trend": "rising" if pkr > 280 else "stable"}
    except Exception as e:
        print(f"⚠️ PKR fallback: {e}")
        return {"usd_to_pkr": 278.5, "trend": "stable"}
