# Extra Credit — Webhook-Triggered Autonomous Agent

**Goal:** Trigger an agentic workflow from an external event instead of a chat message — demonstrating that AI agents are not just chatbots; they can run autonomously in the background, responding to real-world signals.

---

## The Key Concept: Reactive vs. Autonomous

Everything you built in Steps 1–6 used a **Chat Trigger** — a human typed a message, and the agent responded. This is the conversational pattern.

But the agent node in N8N is just a node. The trigger that starts it can be *anything*:

```
Chat Trigger      ──► [Agent] ──► Chat response
Webhook Trigger   ──► [Agent] ──► HTTP response / notification / ticket
Schedule Trigger  ──► [Agent] ──► Email / Webex / report
Meraki Alert      ──► [Agent] ──► Investigates and pages on-call
ThousandEyes Alert──► [Agent] ──► Root-cause analysis, creates ITSM ticket
```

In this assignment you will swap the Chat Trigger for a **Webhook Trigger**. Any system that can send an HTTP POST — monitoring platforms, network devices, scripts, CI/CD pipelines — can now autonomously kick off an AI-powered investigation.

---

## What You Will Build

```
[External System]
       │
       │  HTTP POST (alert payload)
       ▼
[Webhook Trigger]
       │
       ▼
[AI Agent] ◄──── [LLM Model]
    │       ◄──── [Meraki MCP Client]
    │       ◄──── (any other MCP you have connected)
    ▼
[Respond to Webhook]
       │
       │  HTTP response (agent's analysis)
       ▼
[External System receives structured investigation]
```

The agent:

1. Reads the incoming webhook payload as the event to investigate
2. Uses MCP tools to gather additional context
3. Returns a structured analysis as the HTTP response

No human is in the loop. The external system gets back an AI-generated network analysis.

---

## Setup

### Import the Workflow

1. In the workshop N8N instance, create a new workflow.
2. Import `webhook-agent.json` from this folder.
3. If prompted about a missing credential, select the pre-configured shared credential from the dropdown.
4. Click **Save**, then **Activate** the workflow.

> **Important:** The workflow must be **Activated** (not just saved) before the webhook URL is live. The toggle is in the top-right corner of the canvas.

### Get Your Webhook URL

1. Click on the **Webhook Trigger** node.
2. Copy the **Production URL** shown in the node panel. It will look like:
  ```
   https://your-n8n-instance.com/webhook/network-alert
  ```
3. This is the URL you will POST to. Keep it handy.

> **Test URL vs Production URL:** N8N shows both a Test URL (only active while you are viewing the workflow in the editor) and a Production URL (always active when the workflow is activated). Use the **Production URL** for this exercise.

---

## Exercises

### Exercise 1 — Trigger with a basic curl command

The simplest possible trigger. Open a terminal on any machine that can reach the N8N instance and run:

```bash
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"source": "manual-test", "message": "How many clients are on the Meraki network right now?"}' \
  https://YOUR-N8N-URL/webhook/network-alert
```

The agent will receive the JSON body, interpret the `message` field as its task, query Meraki, and return a structured response directly in the curl output — with no human in the loop.

---

### Exercise 2 — Trigger with a simulated Meraki alert

Meraki sends webhook payloads when alerts fire (AP down, rogue AP detected, etc.). This payload mimics the real format:

```bash
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "version": "0.1",
    "sentAt": "2026-04-28T18:00:00Z",
    "networkId": "L_3705899543372507602",
    "networkName": "Main Office",
    "deviceSerial": "Q2AB-1234-5678",
    "deviceName": "Main-AP-01",
    "deviceModel": "MR46",
    "alertType": "Access point went down",
    "alertLevel": "critical",
    "alertData": {
      "trigger": { "ts": 1714320000, "value": false }
    }
  }' \
  https://YOUR-N8N-URL/webhook/network-alert
```

The agent will:

1. Parse the alert payload
2. Recognize that AP `Main-AP-01` (serial `Q2AB-1234-5678`) went down
3. Query Meraki for the device's current status, connected clients, and any related alerts
4. Return an investigation report — no human prompt required

---

### Exercise 3 — Trigger with a simulated ThousandEyes alert

ThousandEyes can also send webhook notifications when tests fail or alerts trigger:

```bash
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "source": "thousandeyes",
    "alertType": "Endpoint Agent Performance Degradation",
    "severity": "high",
    "endpointAgent": "ADUNSMOO-M-RXMV",
    "metric": "packet-loss",
    "value": "18%",
    "threshold": "5%",
    "timestamp": "2026-04-28T18:00:00Z",
    "message": "Endpoint agent ADUNSMOO-M-RXMV is experiencing 18% packet loss, above threshold of 5%."
  }' \
  https://YOUR-N8N-URL/webhook/network-alert
```

The agent will investigate the endpoint in ThousandEyes and correlate with Meraki if connected.

---

### Exercise 4 — Point a real webhook at your agent

If you have access to configure webhooks in any of these systems, point them directly at your N8N webhook URL:

**Meraki:**

1. Dashboard → Network → Alerts → Webhook receivers
2. Add your production webhook URL
3. Trigger a test notification — it fires directly into your agent

**ThousandEyes:**

1. Alerts → Alert Rules → select a rule → Notifications
2. Add a webhook notification with your N8N URL
3. When the alert fires, the agent automatically investigates

**Any other system** (Webex bot, monitoring tool, cron script, CI/CD pipeline):

```bash
# Example: a cron job that asks for a daily network summary
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{"source": "scheduled-report", "message": "Generate a daily network health summary: check Meraki client counts, device status, and any active alerts."}' \
  https://YOUR-N8N-URL/webhook/network-alert
```

---

### Exercise 5 — Swap to a Schedule Trigger (fully autonomous)

The most autonomous pattern of all: the agent runs on a timer, with no external trigger required.

1. Delete the **Webhook Trigger** node.
2. Add a **Schedule Trigger** node (search for "Schedule" in the node picker).
3. Set it to run every morning at 8:00 AM.
4. Connect it to the AI Agent node.
5. Update the system message to ask a standing question:
  ```
   Run a morning network health check. Check:
  ```
  1. How many clients are connected to the Meraki network?
  2. Are there any active device alerts?
  3. Are there any ThousandEyes alerts from the last 12 hours?
    mmarize findings as a morning briefing.
    `
6. Add a **Send Email** or **Webex** node after the agent to deliver the briefing.

Now the agent wakes up every morning, checks the network, and delivers a summary — without anyone typing a single message.

---

## How the Webhook Agent Differs from the Chat Agent


|                   | Chat Agent              | Webhook Agent                                    |
| ----------------- | ----------------------- | ------------------------------------------------ |
| **Trigger**       | Human types a message   | Any HTTP POST from any system                    |
| **Input**         | User's natural language | Structured event payload (JSON)                  |
| **Initiator**     | A person                | A monitoring system, device, script, or schedule |
| **Response**      | Chat reply              | HTTP response + optional downstream action       |
| **Human in loop** | Yes                     | No                                               |
| **Use case**      | Interactive Q&A         | Event-driven automation                          |


Both use the exact same Agent node, LLM, memory, and MCP tools. Only the trigger changes.

---

## Going Further

Once your webhook agent is working, consider chaining actions after the agent's analysis:

- **Create an ITSM ticket** — add an HTTP Request node that POSTs to ServiceNow/Jira with the agent's findings
- **Send a Webex message** — add a Webex node that DMs the on-call engineer with the agent's report
- **Conditional routing** — add an `If` node that only pages someone if the agent's assessment is `critical`
- **Log to a database** — store every agent investigation in a database for audit trail

```
[Webhook] → [AI Agent] → [If: severity == critical?]
                              │ Yes → [Webex: page on-call]
                              │       [ITSM: create incident]
                              └── No → [Log to database]
```

This is where N8N's workflow orchestration and AI agent capabilities combine into something genuinely powerful — not a chatbot, but an autonomous network operations co-pilot.

---

## Key Takeaway

The AI agent does not care how it is invoked. Swap the trigger node, and the same intelligence that answered your chat questions now runs silently in the background, investigating alerts, gathering context, and taking action — at machine speed, at any hour, without waiting for a human to notice and respond.