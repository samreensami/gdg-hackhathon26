from datetime import datetime

def send_slack_alert(channel, message, urgency):
    """
    Creates Slack-format message
    Saves to output/
    """
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    filepath = f"output/slack_alert_{ts}.txt"
    
    content = f"CHANNEL: {channel}\nURGENCY: {urgency}\nMESSAGE: {message}"
    
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)
        
    print(f"💬 Slack alert drafted for {channel}")
    return {"status": "DRAFTED", "saved_to": filepath}
