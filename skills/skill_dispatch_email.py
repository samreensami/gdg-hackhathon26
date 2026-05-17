import os
from datetime import datetime

def send_email_notification(recipient, subject, analyst_output, use_gmail_mcp=False):
    """
    If Gmail MCP is connected: uses real Gmail API (simulated here)
    If not: saves to output/email_drafts/ folder
    Always returns email object with preview
    """
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    email = {
      "to": recipient,
      "subject": subject,
      "body": f"""
Dear Operations Team,

AUTOMATED ALERT - InsightFlow AI System
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ACTION EXECUTED: {analyst_output.get('selected_action')}
TIMESTAMP: {ts}

SITUATION SUMMARY:
{analyst_output.get('insight', {}).get('headline')}

BUSINESS IMPACT:
- Financial Risk: {analyst_output.get('impact', {}).get('financial_display')}
- Orders Affected: {analyst_output.get('impact', {}).get('orders_affected')}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This is an automated message from InsightFlow AI.
Powered by Google Antigravity | AISeekho 2026
      """,
      "status": "DRAFTED",
      "saved_to": f"output/email_drafts/alert_{ts}.txt"
    }
    
    # Save to file
    with open(email['saved_to'], "w", encoding="utf-8") as f:
        f.write(f"TO: {email['to']}\nSUBJECT: {email['subject']}\n\n{email['body']}")
        
    print(f"\n📧 Email drafted: {subject}")
    print("📁 Saved to: output/email_drafts/")
    return email
