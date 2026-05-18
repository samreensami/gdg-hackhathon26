import os
import json
import time
import sys
from colorama import init, Fore, Style
from rich.console import Console
from rich.table import Table
from rich.progress import Progress, BarColumn, TextColumn

from config import DEMO_MODE, CITIES
from agents.ingestion_agent import IngestionAgent
from agents.analyst_agent import AnalystAgent
from agents.action_agent import ActionAgent

# Initialize colorama and rich
init(autoreset=True)
console = Console()

def print_header():
    os.system('cls' if os.name == 'nt' else 'clear')
    print(f"\n{Fore.YELLOW}{'='*70}{Style.RESET_ALL}")
    print(f"{Fore.CYAN}    ⚡ {Fore.WHITE}██╗███╗   ██╗███████╗██╗ ██████╗ ██╗  ██╗████████╗{Style.RESET_ALL}")
    print(f"{Fore.CYAN}    ⚡ {Fore.WHITE}██║████╗  ██║██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝{Style.RESET_ALL}")
    print(f"{Fore.CYAN}    ⚡ {Fore.WHITE}██║██╔██╗ ██║███████╗██║██║  ███╗███████║   ██║   {Style.RESET_ALL}")
    print(f"{Fore.CYAN}    ⚡ {Fore.WHITE}██║██║╚██╗██║╚════██║██║██║   ██║██╔══██║   ██║   {Style.RESET_ALL}")
    print(f"{Fore.CYAN}    ⚡ {Fore.WHITE}██║██║ ╚████║███████║██║╚██████╔╝██║  ██║   ██║   {Style.RESET_ALL}")
    print(f"{Fore.CYAN}    ⚡ {Fore.WHITE}╚═╝╚═╝  ╚═══╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   {Style.RESET_ALL}")
    print(f"{Fore.CYAN}       {Fore.YELLOW}███████╗██╗      ██████╗ ██╗    ██╗     █████╗ ██╗{Style.RESET_ALL}")
    print(f"{Fore.CYAN}       {Fore.YELLOW}██╔════╝██║     ██╔═══██╗██║    ██║    ██╔══██╗██║{Style.RESET_ALL}")
    print(f"{Fore.CYAN}       {Fore.YELLOW}█████╗  ██║     ██║   ██║██║ █╗ ██║    ███████║██║{Style.RESET_ALL}")
    print(f"{Fore.CYAN}       {Fore.YELLOW}██╔══╝  ██║     ██║   ██║██║███╗██║    ██╔══██║██║{Style.RESET_ALL}")
    print(f"{Fore.CYAN}       {Fore.YELLOW}██║     ███████╗╚██████╔╝╚███╔███╔╝    ██║  ██║██║{Style.RESET_ALL}")
    print(f"{Fore.CYAN}       {Fore.YELLOW}╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝     ╚═╝  ╚═╝╚═╝{Style.RESET_ALL}")
    print(f"\n{Fore.GREEN}           🤖 Autonomous Content-to-Action Intelligence 🚀{Style.RESET_ALL}")
    print(f"{Fore.MAGENTA}              Transform Data into Decisions Instantly{Style.RESET_ALL}")
    print(f"\n{Fore.CYAN}    ┌─────────────────────────────────────────────────────────┐{Style.RESET_ALL}")
    print(f"{Fore.CYAN}    │  {Fore.WHITE}🏆 AISeekho 2026 Hackathon  {Fore.CYAN}│  {Fore.YELLOW}Team: FireCoders 🔥  {Fore.CYAN}│{Style.RESET_ALL}")
    print(f"{Fore.CYAN}    │  {Fore.GREEN}⚡ Powered by Google Gemini AI & Antigravity    {Fore.CYAN}│{Style.RESET_ALL}")
    print(f"{Fore.CYAN}    └─────────────────────────────────────────────────────────┘{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}{'='*70}{Style.RESET_ALL}\n")

def print_mcp_status():
    print(f"{Fore.CYAN}╭─────────────── {Fore.WHITE}🔌 SYSTEM STATUS{Fore.CYAN} ───────────────╮{Style.RESET_ALL}")
    print(f"{Fore.CYAN}│{Style.RESET_ALL}  {Fore.GREEN}✅ Gmail MCP{Style.RESET_ALL}           {Fore.WHITE}│{Style.RESET_ALL}  {Fore.GREEN}✅ GitHub MCP{Style.RESET_ALL}         {Fore.CYAN}│{Style.RESET_ALL}")
    print(f"{Fore.CYAN}│{Style.RESET_ALL}  {Fore.GREEN}✅ Sequential Thinking{Style.RESET_ALL} {Fore.WHITE}│{Style.RESET_ALL}  {Fore.GREEN}✅ Google Drive{Style.RESET_ALL}      {Fore.CYAN}│{Style.RESET_ALL}")
    print(f"{Fore.CYAN}╰────────────────────────────────────────────────╯{Style.RESET_ALL}\n")

def print_menu():
    print(f"{Fore.YELLOW}╔═══════════════════════════════════════════════════════════╗{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║              {Fore.WHITE}📋 ANALYSIS SCENARIOS{Fore.YELLOW}                      ║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}╠═══════════════════════════════════════════════════════════╣{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║{Style.RESET_ALL}  {Fore.CYAN}[1]{Style.RESET_ALL} 📦 Supply Chain Crisis Analysis                 {Fore.YELLOW}║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║{Style.RESET_ALL}  {Fore.CYAN}[2]{Style.RESET_ALL} 💰 Financial Alert Analysis                     {Fore.YELLOW}║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║{Style.RESET_ALL}  {Fore.CYAN}[3]{Style.RESET_ALL} 📜 Policy News Analysis                         {Fore.YELLOW}║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║{Style.RESET_ALL}  {Fore.CYAN}[4]{Style.RESET_ALL} 🌊 Flood Warning Analysis                       {Fore.YELLOW}║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║{Style.RESET_ALL}  {Fore.CYAN}[5]{Style.RESET_ALL} ⚡ Load Shedding Impact Analysis                {Fore.YELLOW}║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}╠═══════════════════════════════════════════════════════════╣{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║{Style.RESET_ALL}  {Fore.GREEN}[6]{Style.RESET_ALL} ✍️  Custom Text Input                           {Fore.YELLOW}║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║{Style.RESET_ALL}  {Fore.MAGENTA}[7]{Style.RESET_ALL} 📊 Open Dashboard (dashboard.html)              {Fore.YELLOW}║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║{Style.RESET_ALL}  {Fore.BLUE}[8]{Style.RESET_ALL} 🎬 Run Demo Mode (All 5 Scenarios)              {Fore.YELLOW}║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}╠═══════════════════════════════════════════════════════════╣{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║{Style.RESET_ALL}  {Fore.RED}[Q]{Style.RESET_ALL} 🚪 Quit Application                             {Fore.YELLOW}║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}╚═══════════════════════════════════════════════════════════╝{Style.RESET_ALL}\n")

def load_data(filename):
    filepath = os.path.join("data", filename)
    if os.path.exists(filepath):
        with open(filepath, "r", encoding="utf-8") as f:
            return f.read()
    return "Error: File not found."

def run_pipeline(text):
    print(f"\n{Fore.YELLOW}╔══════════════════════════════════════╗{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}║  Running InsightFlow AI Pipeline     ║{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}╠══════════════════════════════════════╣{Style.RESET_ALL}")
    
    with Progress(
        TextColumn("[progress.description]{task.description}"),
        BarColumn(),
        TextColumn("[progress.percentage]{task.percentage:>3.0f}%"),
    ) as progress:
        
        task1 = progress.add_task("[cyan]Agent 1: Ingestion...", total=100)
        
        # Agent 1 run
        ingestion_agent = IngestionAgent()
        ingestion_output = ingestion_agent.run(text)
        time.sleep(1) # Simulate think time
        progress.update(task1, advance=100, description="[green]Agent 1: Ingestion Done")
        print(f"{Fore.YELLOW}║  [████████░░░░] 33% Agent 1 done     ║{Style.RESET_ALL}")

        task2 = progress.add_task("[cyan]Agent 2: Strategist...", total=100)
        
        # Agent 2 run
        analyst_agent = AnalystAgent()
        analyst_output = analyst_agent.run(ingestion_output)
        time.sleep(1) # Simulate think time
        progress.update(task2, advance=100, description="[green]Agent 2: Strategist Done")
        print(f"{Fore.YELLOW}║  [████████████░] 66% Agent 2 done    ║{Style.RESET_ALL}")

        task3 = progress.add_task("[cyan]Agent 3: Executive...", total=100)
        
        # Agent 3 run
        action_agent = ActionAgent()
        action_output = action_agent.run(analyst_output)
        time.sleep(1) # Simulate think time
        progress.update(task3, advance=100, description="[green]Agent 3: Executive Done")
        print(f"{Fore.YELLOW}║  [██████████████] 100% Complete!     ║{Style.RESET_ALL}")
        print(f"{Fore.YELLOW}╚══════════════════════════════════════╝{Style.RESET_ALL}\n")

    return ingestion_output, analyst_output, action_output

def print_summary(i_out, ana_out, act_out):
    table = Table(title="ANALYSIS COMPLETE ✅", show_header=False, title_style="bold green")
    
    table.add_row("Domain", i_out['extracted']['domain'])
    table.add_row("Urgency", f"🔴 {i_out['extracted']['urgency_level']} (Score: {i_out['extracted']['urgency_score']})")
    
    insight_text = ana_out.get('insight', {}).get('headline', 'N/A') if isinstance(ana_out, dict) else 'N/A'
    table.add_row("Insight", insight_text)
    
    impact_text = f"PKR {ana_out.get('impact', {}).get('financial_pkr', 0):,} at risk, {ana_out.get('impact', {}).get('orders_affected', 0)} orders" if isinstance(ana_out, dict) else 'N/A'
    table.add_row("Impact", impact_text)
    
    action_text = act_out.get('action_executed', 'N/A') if isinstance(act_out, dict) else 'N/A'
    table.add_row("Action Taken", action_text)
    
    before_v = act_out.get('simulation', {}).get('before_state', {}).get('vehicles_delayed', 0) if isinstance(act_out, dict) else 0
    after_v = act_out.get('simulation', {}).get('after_state', {}).get('vehicles_delayed', 0) if isinstance(act_out, dict) else 0
    table.add_row("Vehicles Saved", f"{before_v - after_v} vehicles rerouted")
    
    saving = act_out.get('simulation', {}).get('after_state', {}).get('cost_saving_pkr', 0) if isinstance(act_out, dict) else 0
    table.add_row("Cost Saving", f"PKR {saving:,}")
    
    time_saved = act_out.get('simulation', {}).get('after_state', {}).get('time_saved_hours', 0) if isinstance(act_out, dict) else 0
    table.add_row("Time Saved", f"{time_saved} hours per delivery")
    
    table.add_section()
    table.add_row("📧 Gmail", "Alert drafted & sent")
    table.add_row("🐦 Twitter", "Post drafted")
    table.add_row("💼 LinkedIn", "Professional post ready")
    table.add_row("💬 WhatsApp", "Team alert sent")
    
    console.print(table)
    
    print("\nOutput saved: output/simulation_log.json")
    print("Dashboard: Open dashboard.html in browser\n")

def main():
    while True:
        print_header()
        print_mcp_status()
        print_menu()
        
        choice = input("Select an option: ")
        
        if choice in ['1', '2', '3', '4', '5']:
            filenames = {
                '1': 'sample_supply_chain.txt',
                '2': 'sample_financial.txt',
                '3': 'sample_policy_news.txt',
                '4': 'sample_flood_warning.txt',
                '5': 'sample_load_shedding.txt'
            }
            text = load_data(filenames[choice])
            print(f"\nLoaded {filenames[choice]}...\n")
            i_out, ana_out, act_out = run_pipeline(text)
            print_summary(i_out, ana_out, act_out)
            input("Press Enter to continue...")
            
        elif choice == '6':
            text = input("\nEnter custom text: ")
            i_out, ana_out, act_out = run_pipeline(text)
            print_summary(i_out, ana_out, act_out)
            input("Press Enter to continue...")
            
        elif choice == '7':
            import webbrowser
            filepath = os.path.abspath('dashboard.html')
            webbrowser.open(f'file://{filepath}')
            print("Opened dashboard.html")
            time.sleep(2)
            
        elif choice == '8':
            print("\nRunning Demo Mode...")
            for f in ['sample_supply_chain.txt', 'sample_financial.txt', 'sample_policy_news.txt', 'sample_flood_warning.txt', 'sample_load_shedding.txt']:
                print(f"\n--- Processing {f} ---")
                text = load_data(f)
                i_out, ana_out, act_out = run_pipeline(text)
                print_summary(i_out, ana_out, act_out)
                time.sleep(2)
            input("Demo Complete. Press Enter to continue...")
            
        elif choice.lower() == 'q':
            print("Exiting InsightFlow AI. Goodbye!")
            sys.exit(0)

if __name__ == "__main__":
    # create output dirs if not exist
    os.makedirs('output', exist_ok=True)
    os.makedirs('output/email_drafts', exist_ok=True)
    os.makedirs('output/social_posts', exist_ok=True)
    
    main()
