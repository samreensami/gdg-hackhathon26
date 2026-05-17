import requests

def fetch_pakistan_news(topic="supply chain"):
    try:
        from config_secrets import NEWS_API_KEY
        url = "https://newsapi.org/v2/everything"
        params = {
            "q": f"Pakistan {topic}",
            "language": "en",
            "sortBy": "publishedAt",
            "pageSize": 3,
            "apiKey": NEWS_API_KEY
        }
        r = requests.get(url, params=params, timeout=5)
        data = r.json()
        articles = []
        for a in data.get("articles", []):
            if a.get("title"):
                articles.append({
                    "title": a["title"],
                    "source": a["source"]["name"]
                })
        print(f"📰 News fetched: {len(articles)}")
        return articles
    except Exception as e:
        print(f"⚠️ News fallback: {e}")
        return []

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
