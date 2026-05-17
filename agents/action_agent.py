import json
from datetime import datetime
import os
from skills.skill_execute_simulation import execute_action
from skills.skill_dispatch_email import send_email_notification
from skills.skill_social_post import create_social_posts
from skills.skill_notify_slack import send_slack_alert

class ActionAgent:
    def run(self, analyst_output):
        selected_action = analyst_output.get("selected_action", "ROUTE_ALT_M9")
        actions = analyst_output.get("recommended_actions", [])
        action_detail = next((a for a in actions if a["action_id"] == selected_action), None)
        
        action_title = action_detail["title"] if action_detail else "Activate alternate route via Motorway M-9"
        
        # Simulate action
        simulation_data = execute_action(selected_action, analyst_output)
        
        # Dispatch notifications
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        email_res = send_email_notification(
            "ops-team@logipak.pk", 
            f"Action Executed: {action_title}", 
            analyst_output
        )
        
        social_res = create_social_posts(
            analyst_output.get('insight', {}), 
            action_title, 
            analyst_output.get('impact', {})
        )
        
        slack_res = send_slack_alert(
            "#ops-karachi", 
            f"Automated Action Taken: {action_title}", 
            "HIGH"
        )
        
        output = {
          "agent": "ActionAgent",
          "action_executed": action_title,
          "simulation": simulation_data,
          "notifications_dispatched": {
            "email": email_res,
            "social": social_res,
            "slack": slack_res
          }
        }
        
        # Save log
        with open("output/simulation_log.json", "w", encoding="utf-8") as f:
            json.dump(output, f, indent=2)
            
        return output
