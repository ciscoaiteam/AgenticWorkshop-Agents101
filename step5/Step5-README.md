# Step 5 (Optional) — Deep Dive: ThousandEyes MCP

**Goal:** A focused optional exercise on ThousandEyes endpoint monitoring. Use this step if you want to explore ThousandEyes in depth with a dedicated two-tool agent (Meraki + ThousandEyes only), rather than as part of the full five-MCP setup in Step 5.

---

## Background: Why ThousandEyes + Meraki?

Meraki tells you what the **network** is doing:
- Which devices are connected
- What the configuration looks like
- What alerts the infrastructure has raised

ThousandEyes tells you what **users and endpoints** are experiencing:
- Whether a specific endpoint agent can reach the internet
- Where packet loss or latency is occurring on the network path
- What events or outages have been detected from the user's perspective

Together, they give you a complete picture:

```
User reports: "The internet feels slow"
                        │
          ┌─────────────┴──────────────┐
          ▼                            ▼
   ThousandEyes                      Meraki
   "Endpoint shows 12% packet       "AP is healthy,
    loss to the ISP hop"             uplink is saturated"
          └─────────────┬──────────────┘
                        ▼
         Correlated Answer: "ISP-side issue,
          not your access point"
```

This kind of cross-domain correlation is where agentic workflows genuinely shine — the agent can pull from both tools in a single turn and synthesize an answer a human would take much longer to piece together.

---

## What Changes in This Step

| Before (Step 3) | After (Step 5) |
|---|---|
| Tools: `Meraki MCP Client` only | Tools: `ThousandEyes MCP Client` + `Meraki MCP Client` |
| Persona: Meraki only | Persona: Meraki + ThousandEyes, with `aid` rule |

---

## ThousandEyes MCP Tools Enabled

This workflow enables a curated subset of ThousandEyes tools (not the full catalog):

| Tool | What it does |
|---|---|
| `get_account_groups` | Lists ThousandEyes account groups (use to get the `aid`) |
| `search_outages` | Searches for detected outages in a time range |
| `list_events` | Lists events (alerts, anomalies) |
| `get_event` | Gets details on a specific event |
| `list_endpoint_agents` | Lists all endpoint agents registered in the account |
| `list_endpoint_agent_tests` | Lists scheduled tests for an endpoint agent |
| `get_endpoint_agent_metrics` | Gets performance metrics (latency, loss) for an endpoint |

Selecting a subset of tools keeps the agent focused and avoids token overhead from tools it will never need in this context.

---

## Setup

### Prerequisites

The ThousandEyes API bearer token is **pre-configured** in the workshop environment as a shared Header Auth credential. You do not need to generate your own.

### Option A — Edit Your Step 3 (or Step 4) Workflow Manually

**Add the ThousandEyes MCP Client:**
1. Click the **"+"** (add node) button in the canvas.
2. Search for **MCP Client Tool** and select it.
3. In the node settings:
   - **MCP Endpoint URL:** `https://api.thousandeyes.com/mcp`
   - **Authentication:** Header Auth — select the pre-configured **Header Auth** credential from the dropdown
   - Under **Include Tools**, select: `get_account_groups`, `search_outages`, `list_events`, `get_event`, `list_endpoint_agents`, `list_endpoint_agent_tests`, `get_endpoint_agent_metrics`
4. Connect `ThousandEyes MCP Client` → Agent's **Tools** input.

### Option B — Import the Pre-Built Workflow

1. In the workshop N8N instance, create a new workflow.
2. Import `step5-workflow.json` from this folder.
3. If prompted about missing credentials, select the pre-configured shared credentials from the dropdown — the **OpenAI** credential for the LLM node and the **Header Auth** credential for the ThousandEyes MCP Client.
4. The `Meraki MCP Client` requires no authentication.
5. Save and Activate.

**Update the system prompt:**
1. Double-click the AI Agent node.
2. Add these lines to the Behavior section of the System Message:

```
* When calling any ThousandEyes MCP tool, you MUST always include "aid": "369116"
  in every tool call. Never omit this parameter.
```

3. Update the Role section to mention ThousandEyes.
4. Save.

---

## Exercises

### Exercise 1 — Query ThousandEyes directly

```
Are there any ThousandEyes alerts or outages right now?
```

```
List all endpoint agents in the account.
```

### Exercise 2 — Query your specific endpoint

```
Show me the endpoint agent metrics for ADUNSMOO-M-RXMV
```

```
What tests are scheduled for that endpoint agent?
```

### Exercise 3 — Cross-domain correlation

Try a question that requires both tools:

```
I'm experiencing slow internet. Can you check both Meraki and ThousandEyes to see if there's an issue?
```

Watch the execution panel — you should see the agent:
1. Call a ThousandEyes tool (e.g., `search_outages` or `list_events`)
2. Call a Meraki tool (e.g., `getNetworkClients` or device status)
3. Synthesize both results into a single, correlated answer

### Exercise 4 — Ask about recent events

```
What events have ThousandEyes detected in the last 24 hours?
```

```
Are any of those correlated with changes in the Meraki network?
```

### Exercise 5 — Push the boundaries

```
Which endpoint agent has the worst packet loss, and does Meraki show anything unusual for that device?
```

This requires the agent to:
1. List endpoint agents and their metrics (ThousandEyes)
2. Identify the worst performer
3. Look up that device in Meraki
4. Summarize both perspectives

---

## Key Takeaways

- Two MCP servers give the agent cross-domain visibility with no additional wiring — just connect and ask.
- Curating which tools to expose (not enabling all ~900+ Meraki or all ThousandEyes tools) keeps performance high.
- Mandatory parameters (like `aid` for ThousandEyes) belong in the system prompt, not left to chance.
- This is now a production-quality network operations assistant built entirely in N8N with no custom code.

---

## What You Have Built

You started with a weather chatbot and ended with a network operations assistant that can:

- Query live Meraki network data (clients, devices, configs, alerts)
- Query ThousandEyes endpoint metrics, events, and outages
- Correlate information across both platforms
- Maintain multi-turn conversation context
- Cite its sources in every answer
- Gracefully decline questions outside its scope

All from a no-code visual workflow in N8N.

---

## Where to Go Next

- Add more ThousandEyes tools (test results, path visualization data)
- Connect to additional MCP servers (e.g., Nexus, Intersight, ITSM — covered in Step 4)
- Add N8N workflow actions (e.g., send a Webex message when the agent finds an issue)
- Experiment with different LLMs (GPT-4o, Gemini, local models via Ollama)
- Tune the system prompt for your specific team's terminology and processes
