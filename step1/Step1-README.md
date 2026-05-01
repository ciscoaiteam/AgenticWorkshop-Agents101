# Step 1 — Explore the Weather + News Bot

**Goal:** Understand the five components of an agentic workflow by exploring a working example.

---

## Background: What is an Agentic Workflow?

A traditional automation runs a fixed sequence of steps — A → B → C. An **agentic workflow** is different: the AI agent reads your message, *decides* what to do, calls tools as needed, and synthesizes a response. It can adapt based on context.

Every agentic workflow has five core components:


| Component               | Role                                                | Node in this workflow                 |
| ----------------------- | --------------------------------------------------- | ------------------------------------- |
| **Input**               | Accepts the user's message                          | `Example Chat` (Chat Trigger)         |
| **Agent**               | Reasons, plans, decides which tools to use          | `Your First AI Agent`                 |
| **LLM**                 | The language model that powers the agent's thinking | `Any LLM Chat Model` (OpenAI gpt-5-mini) |
| **Memory**              | Stores recent conversation turns for context        | `Conversation Memory` (Window Buffer) |
| **Tools (not yet MCP)** | External capabilities the agent can call            | `Get Weather` + `Get News`            |


```
[Example Chat]
      │
      ▼
[Your First AI Agent] ◄──── [Any LLM Chat Model]
      │                ◄──── [Conversation Memory]
      │
      ├── calls ──► [Get Weather]  (open-meteo.com API)
      └── calls ──► [Get News]     (RSS feed reader)
```

---

## Setup

1. Log in to the workshop N8N instance (URL and credentials provided by your facilitator).
2. Click **"+"** to create a new workflow.
3. Click the menu (three dots, top right) → **Import from file**.
4. Upload `step1-workflow.json` from this folder.
5. If prompted about a missing credential, select the pre-configured shared credential from the dropdown.
6. Click **Save**, then **Activate** the workflow.

---

## Exercises

### Exercise 1 — Ask the weather bot what to wear

Open the Chat panel and try:

```
What should I wear to visit the Golden Gate Bridge today?
```

Watch the execution panel on the right. You will see:

- The agent receiving your message
- The `Get Weather` tool being called with San Francisco's coordinates
- The agent composing a clothing recommendation from the weather data

### Exercise 2 — Use the news tool for small talk

```
What are some good topics for small talk based on today's news?
```

The agent should call the `Get News` tool to fetch an RSS feed and then summarize topics.

Try combining both:

```
I'm meeting a client in New York today. What's the weather, and what news topics might come up?
```

### Exercise 3 — Disconnect a tool and observe the difference

1. Click on the wire connecting `Get News` to the agent's **Tools** input.
2. Press **Delete** to disconnect it.
3. Ask: `What are the top news stories today?`

Observe: the agent can no longer access news and will either say so or attempt to answer from memory alone — demonstrating that tools are the agent's only window into the real world.

1. Reconnect the wire before moving on.

### Exercise 4 — Inspect the agent persona

1. Double-click the `Your First AI Agent` node.
2. Find the **System Message** field.
3. Read the persona: it describes the agent as a friendly n8n demo assistant.

The persona controls:

- What the agent thinks its job is
- What tone it uses
- What rules it follows

You will change this persona in Step 2.

---

## Key Takeaways

- The **LLM** is the reasoning engine — it decides *what* to do, but cannot act without tools.
- **Tools** are the agent's hands — without them, it can only use its training data.
- **Memory** makes conversations feel natural across multiple turns.
- The **agent persona** (system prompt) shapes behavior without changing the underlying model.
- Disconnecting a tool immediately limits capability — the agent degrades gracefully.

---

## Next Step

Proceed to [Step 2](../step2/Step2-README.md) — Replace the News tool with Meraki MCP and update the agent persona.