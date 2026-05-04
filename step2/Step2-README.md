# Step 2 — Add Meraki MCP + Update Agent Persona

**Goal:** Replace the news tool with Meraki MCP, and immediately update the agent persona to a network engineering assistant — so the agent's identity and toolset are aligned from the start.

---

## Background: Two Changes, One Step

In Step 1 the agent had an identity mismatch waiting to happen: a "friendly demo bot" with weather and news tools. This step fixes both problems at once.

**Part 1 — What is MCP?**

The news tool in Step 1 was hard-coded: one RSS feed reader with a fixed set of URLs. **Model Context Protocol (MCP)** is different — an MCP server advertises a whole collection of tools and the agent discovers which one to use at runtime.

```
Hard-coded tool:   Agent ──► [One fixed API call]

MCP server:        Agent ──► [MCP Client] ──► MCP Server
                                               ├── tool_1: list_clients
                                               ├── tool_2: get_device_status
                                               ├── tool_3: list_organizations
                                               ├── ...
                                               └── tool_N: (nearly 900 Meraki endpoints)
```

The Meraki MCP server wraps the entire Meraki Dashboard API and makes all of it available to the agent as discoverable tools.

**Part 2 — Why the Persona Matters**

The LLM is a general-purpose model. The **system prompt** (agent persona) transforms it into a specialist — like a job description. The same model with a weather-bot persona behaves very differently from one with a network-engineer persona:

```
Persona: "Friendly n8n demo bot"         ──► Enthusiastic, broad, casual
Persona: "Network engineering assistant" ──► Concise, factual, cites sources
```

Changing the persona is free and instant — no retraining, no new model. It is one of the highest-leverage changes you can make to an agent.

---

## What Changes in This Step


| Before (Step 1)                | After (Step 2)                                 |
| ------------------------------ | ---------------------------------------------- |
| `Get News` RSS tool            | `Meraki MCP Client`                            |
| `Get Weather` HTTP tool        | `Get Weather` (unchanged — removed in Step 3)  |
| Persona: friendly n8n demo bot | Persona: concise network engineering assistant |
| No citation rules              | Always cites API calls used                    |
| No default network IDs         | Knows default org ID and network ID            |


Note: the weather tool stays connected for now — this intentional mismatch (a network engineer with a weather tool) motivates Step 3.

---

## Setup

### Modify Your Step 1 Workflow Manually

**Part 1 — Replace the News tool with Meraki MCP:**

1. Click the `Get News` node on the canvas and and click the trash can icon to delete the node.
2. Click **"+"** under the agent's **Tools** input connector.
3. Search for **MCP Client Tool** and select it.
4. Under Paramaters, Set **Endpoint URL** to `https://selent-mcp-selent-mcp.apps.rcdnailab01.ciscoailabs.com/mcp`
5. There is no save button, simply close the node config menu.

---

### Crtically Important — New tools, Old Persona

Your agent has new tools, but the same generic persona. This lack of context for the agents intent or purpose can make answering questions that lack context or specific details challenging. Depending on the model and prior conversations, it might be able to reason out an answer, but it might also burn up all your tokens trying to work it out. 

Try a vague Meraki question such as:

```
What devices are currently connected to my network?
```

Did it answer quickly? Gracefully? Without further follow-ups? Your agents behaviour is heavily influenced by the *System Message!*

## Update the Agent Persona

**Part 2 — Update the agent persona:**

1. Double-click the `Your First AI Agent` node.
2. Scroll to the **System Message** field.
3. Replace the entire contents with the network engineering persona shown below.
4. Close the config menu.

## The Network Engineering Persona

Here an is example for an updated system message. We provide the agent with context around which tools are available, what its behaviour should be, and how it should answer. You might also notice there is provided context for which Meraki organization ID and network ID it should default to, this prevents the agent from asking you for an ID (required context) every time. Try removing it and see what happens.

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
    network ID: L_3705899543372507424

## Answer Format
* Use bullet points or short paragraphs.
* Include a section "Sources checked:" listing the API calls used.
```

Try asking the same question again and see what happens:

```
What devices are currently connected to my network?
```

---

### Setup Option B (If manual edit did not work) — Import the Pre-Built Workflow

1. In the workshop N8N instance, create a new workflow.
2. Import `step2-workflow.json` from this folder.
3. If prompted about a missing credential, select the pre-configured shared credential from the dropdown.
4. The `Meraki MCP Client` requires no authentication in this workshop environment.
5. Close the node config menu — changes save automatically.

---

## Exercises

### Exercise 1 — Check the new greeting

Open a fresh chat and type: `Hello`

The agent should now greet you as a network assistant, not as a generic demo bot. This confirms the persona change is working.

### Exercise 2 — Ask a Meraki question and check the format

```
What clients are currently connected to my network?
```

Watch the execution panel — the agent:

1. Discovers which Meraki tool to call (e.g., `getNetworkClients`)
2. Calls it with the default org and network IDs from the persona
3. Returns a formatted list with a **"Sources checked:"** section at the bottom

The citation format is enforced by the persona — not by the code.

### Exercise 5 — Test the "never invent" rule

```
What is the status of device with hostname "LAS-IS-THE-BEST"
```

The agent should say it does not have that data. The persona instructs it to never invent information — verify it complies.

### Exercise 6 — AI reasoning with network context

The point of having an AI agent is to combine what LLMs are good at: Reasoning, summarization, etc. with YOUR network's state. Try:

```
I need to improve security on this network, what can I do to make it more secure? 
```

### We are using gpt-5-mini, which is a lightweight model. It might struggle with this.  Larger models such as GPT-4o or o3 are better at complex reasoning questions, especially when given credentials and tools to explore the environment.

---

## Key Takeaways

- MCP servers expose many tools through a single connection point — no need to define them one by one.
- The system prompt (persona) is the fastest, cheapest way to change agent behavior — same model, instant transformation.
- Good personas include: role, behavioral rules, output format, and relevant default context (like org/network IDs).
- The agent's identity and toolset should match. Right now they mostly do — except for the weather tool, which gets removed in Step 3.

---

## Next Step

Proceed to [Step 3](../step3/Step3-README.md) — Remove the weather tool and focus the agent on Meraki only.