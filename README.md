# Agentic 101 — N8N Workshop

A hands-on, progressive workshop that teaches the fundamentals of agentic AI workflows using N8N. You will start with a simple weather chatbot and evolve it step-by-step into a Meraki + ThousandEyes network operations assistant.

---

## What You Will Learn


| Component           | What it does                                                         | Where you see it                              |
| ------------------- | -------------------------------------------------------------------- | --------------------------------------------- |
| **Input / Trigger** | Accepts a user message to start the workflow                         | Chat Trigger node                             |
| **LLM**             | The "brain" — reasons, plans, and decides which tools to call        | OpenAI Chat Model node                        |
| **Agent Persona**   | System prompt that defines the assistant's role, rules, and tone     | System Message inside the Agent node          |
| **Memory**          | Stores recent messages so the agent stays on-topic across turns      | Window Buffer Memory node                     |
| **Tools / MCP**     | External capabilities the agent can call (APIs, databases, services) | Weather HTTP tool, RSS tool, MCP Client nodes |


---

## Workshop Progression

```
Step 1 ──► Step 2 ──────────────► Step 3 ──► Step 4 ──► Step 5 (optional)
Explore    Add Meraki MCP          Focus       On-prem     ThousandEyes
Weather    + Network Eng Persona   Toolset     Qwen LLM    deep-dive
+ News     (combined)              (Meraki     + Nexus +
Bot                                only)       Intersight
                                               + ITSM
```


| Step                                         | What changes                                                | Learning objective                                              |
| -------------------------------------------- | ----------------------------------------------------------- | --------------------------------------------------------------- |
| [Step 1](step1/Step1-README.md)              | Nothing — explore the baseline                              | Understand the 5 components of an agentic workflow              |
| [Step 2](step2/Step2-README.md)              | Replace news tool with Meraki MCP + update agent persona    | Understand MCP and how system prompts shape agent behavior      |
| [Step 3](step3/Step3-README.md)              | Remove weather tool                                         | Understand how focused toolsets improve agent accuracy          |
| [Step 4](step4/Step4-README.md)              | Swap to Qwen on-prem LLM + add Nexus, Intersight, ITSM MCPs | Understand data privacy tradeoffs and cross-domain ops          |
| [Step 5](step5/Step5-README.md) *(optional)* | Focused ThousandEyes + Meraki agent                         | Deep-dive into endpoint monitoring and cross-domain correlation |


---

## Getting Started

### Step 0a — Download the Workshop Files

1. Go to the workshop GitHub repository in your browser:
  `**https://github.com/ciscoaiteam/AgenticWorkshop-Agents101*`*
2. Click the green **"Code"** button, then select **"Download ZIP"**.
3. Save and unzip the file to a location you can easily find (e.g. your Desktop).
4. You now have all workflow JSON files and READMEs locally.

### Step 0b — Import StartHere.json into N8N

1. Log in to the workshop N8N instance using the URL and login credentials provided by your session proctor.
2. Click **"+"** to create a new workflow.
3. In the top-right menu (three dots ⋯), select **"Import from file"**.
4. Navigate to the unzipped folder and select `**StartHere.json`**.
5. Click **Save**.

### Step 0c — Add Your OpenAI API Credential

Your session proctor will provide you with an **OpenAI API key**. You need to enter it in N8N before the workflow can run.

1. In your imported workflow, double-click the `**Any LLM Chat Model`** node (the orange node connected to the agent).
2. In the **Credential** field, click **"Create new credential"**.
3. In the credential form, set:
  - **Name:** `OpenAI account`
  - **API Key:** paste the key provided by your session proctor
4. Click **Save** to store the credential.
5. Close the node panel.

> Once saved, this credential is stored in N8N and automatically available when you import later step workflows — you will not need to re-enter the key for each step.

You are now running your first agentic workflow. Proceed to [Step 1](step1/Step1-README.md) to explore how it works.

---

## Prerequisites

### N8N

- Access to the workshop's **N8N on-premise instance** — your facilitator will provide the URL and login credentials
- Basic familiarity with dragging nodes on a canvas

### Credentials


| Credential                            | How you get it                                                  | Used for                      |
| ------------------------------------- | --------------------------------------------------------------- | ----------------------------- |
| **OpenAI API key** (gpt-5-mini)       | Provided by your session proctor — you enter it once in Step 0c | LLM for Steps 1–3 and Step 5  |
| Qwen3.5-9B (on-prem)                  | Pre-configured in the workshop environment                      | LLM for Step 4                |
| Meraki MCP server                     | Pre-configured in the workshop environment                      | Steps 2–4                     |
| ThousandEyes bearer token             | Pre-configured in the workshop environment                      | Step 5                        |
| Nexus / Intersight / ITSM MCP servers | Pre-configured in the workshop environment                      | Step 4 (internal lab cluster) |


If a node shows a credential error after import, re-link it using the credential you created in Step 0c, or ask your session proctor for help.

---

## How to Import a Workflow into N8N

1. Log in to the workshop N8N instance using the URL and credentials provided by your facilitator.
2. Click **"+"** to create a new workflow.
3. In the top-right menu (three dots), select **Import from file**.
4. Upload the `stepN-workflow.json` from the relevant step folder (e.g. `step1-workflow.json` for Step 1).
5. If prompted about a missing credential on the LLM node, select the `**OpenAI account`** credential you created in Step 0c. All other credentials are pre-configured — select them from the dropdown.
6. Click **Save**, then **Activate** the workflow.
7. Open the **Chat** panel and start asking questions.

---

## Key Concepts

### What is MCP?

Model Context Protocol (MCP) is an open standard for giving AI agents access to external tools and data. Instead of hard-coding a single API call, an MCP server exposes many tools that the agent can discover and call dynamically. This makes agents far more capable and reusable.

### Why does the agent persona matter?

The system prompt is the agent's "job description." The same LLM with a weather-bot persona behaves very differently from one with a network-engineer persona. Changing the persona is free and immediate — no retraining required.

### Why limit the toolset?

Research and practice consistently show that giving an LLM too many tools increases hallucination and reduces task accuracy. A focused toolset (under ~15 tools) keeps the agent reliable and predictable.

---

## Files in This Repository

```
Agentic101/
├── README.md                ← This file
├── StartHere.json           ← Original N8N Weather + News workflow (reference)
├── EndGoal.json             ← Final all-MCP workflow with Qwen (reference)
├── step1/
│   ├── Step1-README.md
│   └── step1-workflow.json
├── step2/                   ← Meraki MCP + Network Eng Persona (combined)
│   ├── Step2-README.md
│   └── step2-workflow.json
├── step3/
│   ├── Step3-README.md
│   └── step3-workflow.json
├── step4/
│   ├── Step4-README.md
│   └── step4-workflow.json
├── step5/                   ← Optional ThousandEyes deep-dive
│   ├── Step5-README.md
│   └── step5-workflow.json
└── step6 Extra Credit/
    ├── WEBHOOK_AGENT.md     ← Trigger an agent from any external event (no chat required)
    ├── webhook-agent.json   ← N8N workflow for the webhook agent
    └── MCP_SCANNER.md       ← Scan MCP servers for security threats
```

---

## Extra Credit Assignments


| Assignment                                              | Concept                                                     | Files                                                 |
| ------------------------------------------------------- | ----------------------------------------------------------- | ----------------------------------------------------- |
| [Webhook-Triggered Agent](ExtraCredit/WEBHOOK_AGENT.md) | Agents run autonomously from external events, not just chat | `ExtraCredit/WEBHOOK_AGENT.md` + `webhook-agent.json` |
| [MCP Security Scanner](ExtraCredit/MCP_SCANNER.md)      | Scan MCP servers for prompt injection and tool poisoning    | `ExtraCredit/MCP_SCANNER.md` + `scan-mcps.sh`         |


