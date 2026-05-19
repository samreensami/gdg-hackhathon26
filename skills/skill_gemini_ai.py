import google.generativeai as genai
import os
import json

GEMINI_KEY = os.environ.get('GEMINI_API_KEY', '')
if GEMINI_KEY:
    genai.configure(api_key=GEMINI_KEY)

def call_gemini_chat(message, history=[], system_prompt=None):
    try:
        if not system_prompt:
            system_prompt = """
# IDENTITY & FRAMEWORK CONTEXT
You are the core "InsightFlow AI Agent", running on the Google Antigravity Agentic Architecture. Your purpose is an Autonomous Content-to-Action Agent specializing in simulating Pakistan's macro-environmental risk scenarios.

# DISPATCHER RULES
1. DO NOT fallback to the default greeting or static informational text ("Run our all scenarios...") once the simulation sequence starts.
2. Intercept every user query dynamically. Treat variations of keywords (e.g., "financial alert", "load shedding", "flood", "supply chain", "policy") as direct system intents.

# ANCHORED SCENARIOS (PAKISTAN CONTEXT)
- Scenario 1: Supply Chain Crisis (Port delays, highway blockades, distribution network inflation).
- Scenario 2: Flood Warning (NDMA alerts, monsoon agriculture impact, infrastructure damage).
- Scenario 3: Load Shedding (Circular debt spikes, industrial grid failures, manufacturing capacity drop).
- Scenario 4: Financial Alert (IMF structural adjustments, FBR tax enforcement, PKR/USD volatility).
- Scenario 5: Policy News (Petroleum levy adjustments, regulatory tariffs, energy pricing updates).

# EXECUTION ENGINE & RESPONSE SPECIFICATION
When an intent is intercepted, output an expert-level consultancy framework optimized for mobile frames:
- **Financial Loss Matrix:** State estimated impact dynamically in PKR (Millions/Billions) matching the scale of the current issue.
- **Business Downstream Impact:** Detail a logical chain reaction affecting companies and dependencies.
- **Action Plan Executed:** Generate concrete, step-by-step mitigation workflows that the automated pipeline can process.

# OUTPUT STYLE GUIDELINES
- No verbose preamble. No robotic repetition of the onboarding menu.
- Use sharp, professional, corporate consulting prose.
- Use bullet points and bold headers to maintain high readability on small mobile viewports.
"""
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            system_instruction=system_prompt
        )
        
        response = model.generate_content(
            message,
            generation_config={"temperature": 0.7, "max_output_tokens": 500}
        )
        
        if response and response.text:
            return response.text.strip()
        return "Pakistan ke liye yahan hoon! Koi scenario run karein?"
        
    except Exception as e:
        print(f"Gemini chat error: {e}")
        return "Connection error. Main yahan Pakistan ki help ke liye hoon!"

def analyze_with_gemini(raw_text, scenario_type):
    """
    Expert Analysis for InsightFlow Agent Pipeline.
    Returns structured JSON with insight, before_state, impact, and action_executed.
    """
    try:
        prompt = f"""
Analyze this Pakistan business scenario: {scenario_type}
Content: {raw_text}

OUTPUT ONLY VALID JSON:
{{
  "insight": "One line sharp insight about the bottleneck",
  "before_state": {{
    "metric1": "value",
    "metric2": "value"
  }},
  "impact": {{
    "financial_display": "PKR XM (e.g. PKR 4.5M)",
    "financial_pkr": 4500000
  }},
  "action_executed": "Clear step-by-step mitigation action"
}}
"""
        model = genai.GenerativeModel("gemini-1.5-flash")
        response = model.generate_content(
            prompt,
            generation_config={
                "temperature": 0.2,
                "response_mime_type": "application/json"
            }
        )
        
        if response and response.text:
            return json.loads(response.text)
        return None
        
    except Exception as e:
        print(f"Analysis error: {e}")
        return None
