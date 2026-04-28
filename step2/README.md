# Step 2 — Replace News with Meraki MCP

**Goal:** Understand what MCP is and why it is more powerful than a single hard-coded tool. Replace the RSS news tool with a Meraki MCP server.

---

## Background: What is MCP?

In Step 1, the agent used two hard-coded tools:
- `Get Weather` — a single HTTP call to one specific API with a fixed schema
- `Get News` — a single RSS reader that fetches from pre-defined feeds

**Model Context Protocol (MCP)** takes a different approach. An MCP server is a remote service that *advertises* a collection of tools. When the agent connects to an MCP server, it can discover all available tools dynamically and pick the right one at runtime.

```
Hard-coded tool:   Agent ──► [One fixed API call]

MCP server:        Agent ──► [MCP Client] ──► MCP Server
                                               ├── tool_1: list_clients
                                               ├── tool_2: get_device_status
                                               ├── tool_3: list_organizations
                                               ├── ...
                                               └── tool_N: (nearly 900 Meraki endpoints)
```

The Meraki MCP server used in this workshop wraps the entire Meraki Dashboard API (~900 endpoints) and makes all of them available to the agent as tools.

---

## What Changes in This Step

| Before (Step 1) | After (Step 2) |
|---|---|
| `Get News` (RSS feed tool) | `Meraki MCP Client` |
| `Get Weather` (HTTP tool) | `Get Weather` (unchanged) |

The agent persona stays the same for now — that changes in Step 3.

---

## Setup

### Option A — Import the Pre-Built Workflow

1. In the workshop N8N instance, create a new workflow.
2. Import `workflow.json` from this folder.
3. If prompted about a missing credential, select the pre-configured shared credential from the dropdown.
4. The `Meraki MCP Client` node requires no authentication in this workshop environment.
5. Save and Activate.

### Option B — Modify Your Step 1 Workflow Manually

This teaches you how to edit a workflow in place.

**Remove the News tool:**
1. Click the `Get News` node on the canvas.
2. Press **Delete** (or right-click → Delete).
3. The wire to the agent is automatically removed.

**Add the Meraki MCP Client:**
1. Click **"+"** in the canvas (or click the `+` icon under the agent's **Tools** input connector).
2. Search for **MCP Client Tool** and select it.
3. In the node settings, set:
   - **MCP Endpoint URL:** `https://selent-mcp-selent-mcp.apps.rcdnailab01.ciscoailabs.com/mcp`
   - Leave all other settings as default.
4. Draw a wire from `Meraki MCP Client` → Agent's **Tools** input.
5. Save and Activate.

---

## Exercises

### Exercise 1 — Ask a Meraki question

```
What clients are currently connected to my network?
```

Watch the execution panel — you will see the agent:
1. Receive your message
2. Discover which Meraki tool to call (e.g., `getNetworkClients`)
3. Call the tool with the correct organization and network IDs
4. Return a formatted list of clients

### Exercise 2 — Mix weather and network data

```
What is the weather in San Jose today, and how many devices are on my Meraki network?
```

The agent will call *both* tools in a single response, demonstrating that it can orchestrate multiple tool calls within one turn.

### Exercise 3 — Explore Meraki device data

```
Show me the firmware versions for all devices on my network.
```

```
What is the status of my Meraki access points?
```

### Exercise 4 — Ask something the agent cannot answer

```
What are the top tech news stories today?
```

Since `Get News` was removed, the agent has no news tool. Observe how it responds — it should acknowledge the limitation rather than hallucinate.

---

## What to Notice

- **Tool discovery:** The MCP client automatically discovers all available Meraki tools. You did not need to define them one by one.
- **Graceful degradation:** Removing a tool makes the agent acknowledge it can't help with that topic, rather than making things up.
- **Multi-tool calls:** The agent seamlessly combines weather (HTTP tool) and Meraki data (MCP tool) in one answer.

---

## Key Takeaways

- MCP servers expose many tools through a single connection point, making agents far more capable without extra wiring.
- The agent still has an identity crisis — it is still a "friendly n8n demo agent" trying to answer Meraki questions. That gets fixed in Step 3.
- Mixing unrelated tools (weather + network) works, but it can confuse the agent's focus. That gets fixed in Step 4.

---

## Next Step

Proceed to [Step 3](../step3/README.md) — Change the agent persona to a network engineering assistant.
