import json
import os
import time

def get_business_rules(domain="logistics"):
    """Reads business_rules.json, returns relevant rules"""
    # Simulate DB query
    time.sleep(0.5)
    
    filepath = os.path.join("data", "business_rules.json")
    if os.path.exists(filepath):
        with open(filepath, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}
