# Agentic 101 — N8N Workshop

A hands-on, progressive workshop that teaches the fundamentals of agentic AI workflows using N8N. You will start with a simple weather chatbot and evolve it step-by-step into a Meraki + ThousandEyes network operations assistant.

---

## What You Will Learn

| Component | What it does | Where you see it |
|---|---|---|
| **Input / Trigger** | Accepts a user message to start the workflow | Chat Trigger node |
| **LLM** | The "brain" — reasons, plans, and decides which tools to call | Claude Haiku model node |
| **Agent Persona** | System prompt that defines the assistant's role, rules, and tone | System Message inside the Agent node |
| **Memory** | Stores recent messages so the agent stays on-topic across turns | Window Buffer Memory node |
| **Tools / MCP** | External capabilities the agent can call (APIs, databases, services) | Weather HTTP tool, RSS tool, MCP Client nodes |

---

## Workshop Progression

```
Step 1 ──► Step 2 ──► Step 3 ──► Step 4 ──► Step 5 (optional)
Explore    Add        Change      Focus       Add
Weather    Meraki     Persona     Toolset     ThousandEyes
+ News     MCP        to NetEng   (Meraki     MCP
Bot                               only)
```

| Step | What changes | Learning objective |
|---|---|---|
| [Step 1](step1/README.md) | Nothing — explore the baseline | Understand the 5 components of an agentic workflow |
| [Step 2](step2/README.md) | Replace RSS news tool with Meraki MCP | Understand what MCP is and why it matters |
| [Step 3](step3/README.md) | Update agent persona to network engineer | Understand how system prompts shape agent behavior |
| [Step 4](step4/README.md) | Remove weather tool | Understand how focused toolsets improve agent accuracy |
| [Step 5](step5/README.md) | Add ThousandEyes MCP | Understand multi-source correlation in network ops |

---

## Prerequisites

### N8N
- An active [N8N Cloud](https://n8n.io/) account (free trial works)
- Basic familiarity with dragging nodes on a canvas

### API Credentials
You will need at least one LLM credential configured in N8N:

| Provider | Where to get a key |
|---|---|
| Anthropic (Claude) | [console.anthropic.com](https://console.anthropic.com/) |
| OpenAI (GPT) | [platform.openai.com](https://platform.openai.com/) |

For Steps 2–4 you will also need access to the **Meraki MCP server**. For Step 5 you will need a **ThousandEyes bearer token**.

---

## How to Import a Workflow into N8N

1. In your N8N instance, click **"+"** to create a new workflow.
2. In the top-right menu (three dots), select **Import from file**.
3. Upload the `workflow.json` from the relevant step folder.
4. Configure any credentials prompted by N8N (LLM model, auth headers).
5. Click **Save**, then **Activate** the workflow.
6. Open the **Chat** panel and start asking questions.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     N8N Workflow                        │
│                                                         │
│  [Chat Trigger] ──► [AI Agent Node]                     │
│                          │                              │
│                    ┌─────┴──────┐                       │
│                    │            │                        │
│               [LLM Model]  [Memory]                     │
│                                                         │
│                    [Tools / MCP Clients]                 │
│                    ├── Get Weather (HTTP)                │
│                    ├── Get News (RSS)                    │
│                    ├── Meraki MCP Client                 │
│                    └── ThousandEyes MCP Client           │
└─────────────────────────────────────────────────────────┘
```

The agent receives a message, reasons about which tools to call, executes them, and synthesizes a final answer — all in a single workflow execution.

---

## Key Concepts

### What is an MCP?
Model Context Protocol (MCP) is an open standard for giving AI agents access to external tools and data. Instead of hard-coding a single API call, an MCP server exposes many tools that the agent can discover and call dynamically. This makes agents far more capable and reusable.

### Why does the agent persona matter?
The system prompt is the agent's "job description." The same LLM with a weather-bot persona behaves very differently from one with a network-engineer persona. Changing the persona is free and immediate — no retraining required.

### Why limit the toolset?
Research and practice consistently show that giving an LLM too many tools increases hallucination and reduces task accuracy. A focused toolset (under ~15 tools) keeps the agent reliable and predictable.

---

## Files in This Repository

```
Agentic101/
├── README.md            ← This file
├── StartHere.json       ← Original N8N Weather + News workflow (reference)
├── EndGoal.json         ← Final Meraki + ThousandEyes workflow (reference)
├── step1/
│   ├── README.md
│   └── workflow.json
├── step2/
│   ├── README.md
│   └── workflow.json
├── step3/
│   ├── README.md
│   └── workflow.json
├── step4/
│   ├── README.md
│   └── workflow.json
└── step5/
    ├── README.md
    └── workflow.json
```
