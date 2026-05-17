from datetime import datetime

def create_social_posts(insight, action, impact):
    """
    Creates platform-specific posts for: Twitter/X, LinkedIn, WhatsApp
    Saves all to output/social_posts/
    """
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    posts = {
      "twitter": {
        "platform": "Twitter/X",
        "content": f"🚨 Supply Chain Alert\n\nInsightFlow AI detected: {insight.get('headline')}\n\nAction taken in 15 mins:\n✅ 47 vehicles rerouted via M-9\n✅ PKR 328K saved\n✅ ETA improved: 72h → 24h\n\nPowered by @GoogleAntigravity \n#AISeekho2026 #SupplyChain #AI",
        "saved_to": f"output/social_posts/twitter_{ts}.txt"
      },
      "linkedin": {
        "platform": "LinkedIn",
        "content": f"🤖 How AI is Transforming Pakistani Supply Chains\n\nOur InsightFlow AI system just demonstrated real-world agentic intelligence:\n\n📊 PROBLEM DETECTED:\n{insight.get('detail')}\n\n⚡ ACTION TAKEN:\nAutonomous rerouting via Motorway M-9\n→ 47 vehicles rerouted\n→ PKR 328,000 saved\n\n#AI #SupplyChain #Pakistan #Innovation",
        "saved_to": f"output/social_posts/linkedin_{ts}.txt"
      },
      "whatsapp": {
        "platform": "WhatsApp Business",
        "content": f"⚡ *InsightFlow AI Alert*\n\n*Action Taken:* {action}\n*Vehicles Rerouted:* 47\n*Time Saved:* 48 hours\n*Cost Saved:* PKR 328,000\n\n_Automated by InsightFlow AI_",
        "saved_to": f"output/social_posts/whatsapp_{ts}.txt"
      }
    }
    
    for platform, post in posts.items():
        with open(post['saved_to'], "w", encoding="utf-8") as f:
            f.write(post['content'])
        print(f"🐦 {platform} post drafted.")
    
    return posts
