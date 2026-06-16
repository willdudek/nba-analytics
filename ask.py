import anthropic
import duckdb
import re
import os
import json
from datetime import datetime

# Load system prompt from generated file — run generate_prompt.py to refresh
PROMPT_PATH = os.path.join(os.path.dirname(__file__), "system_prompt.txt")
with open(PROMPT_PATH) as f:
    SYSTEM_PROMPT = f.read()

LOG_PATH = os.path.join(os.path.dirname(__file__), "query_log.json")

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY")
MOTHERDUCK_TOKEN = os.environ.get("MOTHERDUCK_TOKEN")

client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)
conn = duckdb.connect(f"md:?motherduck_token={MOTHERDUCK_TOKEN}")

conversation_history = []

def extract_sql(text):
    matches = re.findall(r"```sql\n(.*?)```", text, re.DOTALL)
    if matches:
        return matches[-1].strip()
    return None

def extract_table(text):
    """Pull the table name Claude says it's querying from its reasoning."""
    match = re.search(r"my_db\.main\.(\w+)", text)
    if match:
        return match.group(1)
    return "unknown"

def run_query(sql):
    try:
        result = conn.execute(sql).fetchdf()
        return result, None
    except Exception as e:
        return None, str(e)

def log_exchange(question, table, sql, answer, error=None):
    entry = {
        "timestamp": datetime.now().isoformat(),
        "question": question,
        "table_used": table,
        "sql": sql,
        "answer": answer,
        "error": error
    }
    # append to log file
    log = []
    if os.path.exists(LOG_PATH):
        with open(LOG_PATH) as f:
            try:
                log = json.load(f)
            except json.JSONDecodeError:
                log = []
    log.append(entry)
    with open(LOG_PATH, "w") as f:
        json.dump(log, f, indent=2)

def ask(question):
    print(f"\nQuestion: {question}\n")

    conversation_history.append({"role": "user", "content": question})

    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1000,
        system=SYSTEM_PROMPT,
        messages=conversation_history
    )

    claude_response = response.content[0].text
    print("Claude's reasoning and SQL:")
    print(claude_response)

    conversation_history.append({"role": "assistant", "content": claude_response})

    sql = extract_sql(claude_response)
    table = extract_table(claude_response)

    if sql:
        print("\nExecuting query against MotherDuck...\n")
        results, error = run_query(sql)

        if error:
            print(f"Query error: {error}")
            log_exchange(question, table, sql, answer=None, error=error)
        else:
            print("Results:")
            print(results)

            summary_response = client.messages.create(
                model="claude-sonnet-4-6",
                max_tokens=500,
                system=SYSTEM_PROMPT,
                messages=conversation_history + [
                    {"role": "user", "content": f"Here are the query results:\n{results.to_string()}\n\nPlease summarize the answer in plain English."}
                ]
            )

            summary = summary_response.content[0].text
            print("\nAnswer:")
            print(summary)

            conversation_history.append({"role": "user", "content": f"Here are the query results:\n{results.to_string()}\n\nPlease summarize the answer in plain English."})
            conversation_history.append({"role": "assistant", "content": summary})

            log_exchange(question, table, sql, answer=summary)
    else:
        print("\nNo SQL query generated.")
        log_exchange(question, table, sql=None, answer=claude_response)

print("NBA Analytics Assistant. Type 'quit' to exit.\n")
print(f"System prompt loaded from: {PROMPT_PATH}")
print(f"Query log: {LOG_PATH}\n")
while True:
    question = input("Ask a question: ").strip()
    if question.lower() in ("quit", "exit", "q"):
        break
    if question:
        ask(question)
