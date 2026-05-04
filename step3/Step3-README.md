# Step 3 — Focus the Agent (Remove Weather Tool)

**Goal:** Understand why a focused, minimal toolset produces a more reliable, predictable agent.

---

## Background: The Tool Overload Problem

Every tool you attach to an agent increases the cognitive load on the LLM. Before responding, the model must:

1. Read all tool descriptions
2. Evaluate whether any tool is relevant to the current query
3. Decide which tool to call (or not call)
4. Parse and use the tool's output

When tools are unrelated to each other or to the agent's purpose, this process becomes noisy. Research and practice consistently show:

- **More tools → more confusion** — the model occasionally picks the wrong tool
- **More tools → more tokens** — tool definitions consume prompt space on every turn
- **More tools → less predictable behavior** — harder to debug and trust

The rule of thumb: **keep your agent's toolset under ~15 tools, all relevant to the same domain.**

In Step 2, the agent had two tools: `Get Weather` and `Meraki MCP Client`. For a network engineering assistant, weather is irrelevant. Removing it makes the agent sharper.

---

## What Changes in This Step


| Before (Step 2)                                 | After (Step 3)                          |
| ----------------------------------------------- | --------------------------------------- |
| Tools: `Get Weather` + `Meraki MCP Client`      | Tools: `Meraki MCP Client` only         |
| Persona: Network engineer (with weather access) | Persona: Network engineer (Meraki only) |
| System prompt mentions weather tool             | System prompt updated — weather removed |


---

## Setup

### Edit Your Step 2 Workflow Manually

1. Click the `Get Weather` node on the canvas.
2. Press **Delete** (or right-click → Delete).
3. The wire to the agent is automatically removed.
4. Double-click `Your First AI Agent` → remove the weather tool mention at the top of the the System Message. One line: "* Weather ([open-meteo.com](http://open-meteo.com))".
5. Close the node config menu — changes save automatically.

---

### Exercise Multi-turn Meraki conversation

Try this sequence without refreshing:

```
List all clients connected to the network.
```

```
Which of those are wireless vs. wired?
```

```
How long has the client with the highest data usage been connected?
```

The agent stays on-topic across all three turns, using memory to avoid re-fetching data.

---

## Comparing Step 1 → Step 3


|                  | Step 1            | Step 3                        |
| ---------------- | ----------------- | ----------------------------- |
| Tools            | Weather + News    | Meraki MCP only               |
| Persona          | Friendly demo bot | Network engineering assistant |
| Weather question | Real answer       | Graceful decline              |
| News question    | Real answer       | Graceful decline              |
| Network question | No tools for this | Full Meraki access            |
| Response format  | Conversational    | Structured, cites sources     |
| Reliability      | Medium            | High                          |


---

## Key Takeaways

- Removing a tool is as powerful as adding one — it eliminates a category of errors.
- A well-focused agent is more trustworthy in production than a "do-everything" agent.
- Graceful degradation (saying "I can't" rather than hallucinating) is a sign of good agent design.
- The system prompt and toolset should always match each other — misalignment creates confusion.

---

## Next Step

This is a complete, focused Meraki assistant. Proceed to [Step 4](../step4/Step4-README.md) — swap the LLM to an on-premises Qwen model and expand the toolset with Nexus, Intersight, and ITSM MCP servers.