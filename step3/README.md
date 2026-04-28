# Step 3 — Change the Agent Persona

**Goal:** Understand how the system prompt (agent persona) shapes agent behavior — without changing the model or the tools.

---

## Background: The System Prompt is the Agent's Job Description

The LLM in your workflow is a general-purpose model. Left to its own devices, it will try to be helpful to anyone about anything. The **system prompt** (also called the agent persona) transforms it into a specialist.

Think of it like hiring someone: the LLM is the candidate, the tools are their skills, and the system prompt is the job description and company handbook.

```
Same LLM + Same Tools, Different Persona:

Persona: "Friendly n8n demo bot"     ──► Enthusiastic, broad, casual answers
Persona: "Network engineering asst"  ──► Concise, factual, cites sources
```

Changing the persona is free, instant, and requires no retraining. It is one of the highest-leverage changes you can make to an agent.

---

## What Changes in This Step

| Before (Step 2) | After (Step 3) |
|---|---|
| Persona: friendly n8n demo bot | Persona: concise network engineering assistant |
| No rules on citation | Always cites API calls used |
| No default network context | Knows default org ID and network ID |
| Tools: Weather + Meraki MCP | Tools: Weather + Meraki MCP (unchanged) |

Note: The weather tool is still connected, even though the persona is now a network engineer. This creates an intentional tension — the agent *can* answer weather questions, but it feels out of place. That gets resolved in Step 4.

---

## The New Persona

The system message now reads:

```
# Network Agent

## Role
You are a concise, factual network engineering assistant with access to these tools:
* Meraki (Network Management Platform)
* Weather (open-meteo.com)

## Behavior
* On the first message only, greet the user and say you can assist with network operations.
* Never invent information. Only use content found in the tools.
* Be efficient. Gather only the data needed to answer the question.
* When calling Meraki MCP tools, default to:
    organization ID: 3705899543372497758
    network ID: L_3705899543372507602

## Answer Format
* Use bullet points or short paragraphs.
* Include a section "Sources checked:" listing the API calls used.
```

---

## Setup

### Option A — Import the Pre-Built Workflow

1. In the workshop N8N instance, create a new workflow.
2. Import `workflow.json` from this folder.
3. If prompted about a missing credential, select the pre-configured shared credential from the dropdown.
4. Save and Activate.

### Option B — Edit Your Step 2 Workflow Manually

1. Double-click the `Your First AI Agent` node.
2. Scroll to the **System Message** field.
3. Replace the entire contents with the network engineering persona above (or copy from `EndGoal.json`).
4. Save.

---

## Exercises

### Exercise 1 — Compare the greeting

Open a fresh chat and just say: `Hello`

With the new persona, the agent should greet you as a network assistant rather than as a general demo bot.

### Exercise 2 — Ask a Meraki question and check the format

```
What clients are connected to my network?
```

Look for the **"Sources checked:"** section at the bottom. The new persona enforces this format so you always know which API calls were made.

### Exercise 3 — Ask the same question three different ways

Try these in succession (without refreshing — the memory carries context):

```
How many clients are online?
```

```
Which of those clients have been connected the longest?
```

```
Is any of them using more than 1GB of data?
```

The agent should use memory to maintain context rather than re-fetching client data on each turn.

### Exercise 4 — Ask a weather question

```
What is the weather in San Jose today?
```

The agent will answer (the weather tool is still connected), but the response tone is now more factual and professional. Notice how awkward it feels for a "network engineering assistant" to be answering weather questions — this motivates Step 4.

### Exercise 5 — Test the "never invent" rule

Ask something the agent cannot know from its tools:

```
What is the historical uptime percentage of my network over the past year?
```

The agent should say it does not have that data, not fabricate a number.

---

## Key Takeaways

- The system prompt is the cheapest, most powerful way to customize agent behavior.
- Good personas include: role definition, behavioral rules, output format requirements, and relevant context (like default IDs).
- Memory makes multi-turn conversations coherent — the agent does not forget what it already fetched.
- Having tools that do not match the persona creates confusion. The agent might still use them, but it feels off — which is by design to motivate Step 4.

---

## Next Step

Proceed to [Step 4](../step4/README.md) — Remove irrelevant tools and focus the agent on Meraki only.
