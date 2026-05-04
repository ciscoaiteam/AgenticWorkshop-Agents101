# Step 4 — On-Prem LLM (Qwen) + Additional MCP Servers

**Goal:** Replace the cloud LLM with an on-premises model for data privacy, and expand the agent's capabilities with three additional MCP servers covering data center switching, compute infrastructure, and IT service management.

---

## Background: Why Run an LLM On-Premises?

In every step so far, your conversations have been processed by a cloud API (OpenAI). Every message you send — and every tool response the agent receives — is transmitted to OpenAI's servers for inference.

For many enterprise network operations scenarios, this is a concern:

- **Sensitive data in tool responses:** client MAC addresses, IP allocations, device hostnames, firmware versions, incident tickets, and change records all pass through the LLM
- **Compliance and data sovereignty:** some regulated environments prohibit sending operational data to third-party cloud APIs
- **Cost at scale:** cloud API pricing scales with token volume; large toolsets generate large tool responses

**On-premises LLMs** solve this by running the model inside your own infrastructure. No data leaves your perimeter.

---

## The Tradeoff: Capability vs. Privacy


|                       | Cloud LLM (gpt-5-mini)         | On-Prem LLM (Qwen3.5-9B)         |
| --------------------- | ------------------------------ | -------------------------------- |
| **Data privacy**      | Data sent to OpenAI            | All data stays on-prem           |
| **Context window**    | 128K tokens                    | ~8K–32K tokens (model-dependent) |
| **Response speed**    | Fast (OpenAI's infrastructure) | Depends on your GPU              |
| **Reasoning quality** | Higher (larger model)          | Good for focused tasks           |
| **Cost**              | Per-token API pricing          | Fixed infrastructure cost        |
| **Model updates**     | Automatic                      | Manual                           |


For focused, domain-specific agents like this network assistant, a smaller 9B-parameter model performs well — especially when the system prompt and toolset are tightly scoped.

---

## What Changes in This Step


| Before (Step 3)                | After (Step 4)                                           |
| ------------------------------ | -------------------------------------------------------- |
| LLM: OpenAI gpt-5-mini (cloud) | LLM: Qwen3.5-9B (on-prem)                                |
| Tools: Meraki only             | Tools: Meraki + Nexus + Intersight + ITSM + ThousandEyes |
| Persona: Meraki only           | Persona: 5 tools listed                                  |


---

## Part 1 — Swap to Qwen On-Premise LLM

### Option A — Edit Your Step 3 Workflow Manually

1. In your Step 3 workflow, click **"+"** at the top right or right-click the mouse to add a new node.
2. Search for **OpenAI Chat Model** (N8N uses this type for any OpenAI-compatible API).
3. In the node settings, select "Create Credential"
4. Replace the **Base URL** with this: [https://qwen35-9b.apps.rcdnailab01.ciscoailabs.com/v1](https://qwen35-9b.apps.rcdnailab01.ciscoailabs.com/v1)
5. Enter anything into the API Key (there is no authorization)
6. Draw a wire from `Qwen3 LLM` → Agent's **AI Language Model** input.
7. Disconnect the existing OpenAI wire (click it, press Delete).
8. Keep the OpenAI node on the canvas but unconnected — you will A/B test with it later.

### Option B — Import the Pre-Built Workflow

1. In the workshop N8N instance, create a new workflow.
2. Import `step4-workflow.json` from this folder.
3. If prompted about missing credentials, select the pre-configured shared credentials from the dropdown — the **QWEN** credential for the Qwen node and the **OpenAI** credential for the OpenAI node.
4. The `OpenAI Chat Model` node is kept but disconnected — use it to A/B test responses.
5. Close the node config menu — changes save automatically.

### What is an OpenAI-Compatible API?

Most on-premises LLM runtimes (vLLM, Ollama, LM Studio, llama.cpp server) expose an API that mimics the OpenAI `/v1/chat/completions` endpoint. N8N's OpenAI Chat Model node works with any of these without code changes — just point it at a different base URL.

---

## Part 2 — Add Three New MCP Servers

### The New MCP Servers


| MCP Server     | Endpoint                                                   | What it provides                                |
| -------------- | ---------------------------------------------------------- | ----------------------------------------------- |
| **Nexus**      | `http://mcp-nexus.n8n-lab.svc.cluster.local:8011/mcp`      | Cisco Nexus switch config, VLANs, topology      |
| **Intersight** | `http://mcp-intersight.n8n-lab.svc.cluster.local:8010/mcp` | UCS server inventory, firmware, hardware health |
| **ITSM**       | `http://mcp-itsm.n8n-lab.svc.cluster.local:8012/mcp`       | Change requests, incidents, knowledge base      |


These endpoints are internal to the lab cluster (`svc.cluster.local`). In your own environment, replace with your actual MCP server URLs.

### Adding Each MCP Client (repeat for all three)

1. Click **"+"** in the canvas.
2. Search for **MCP Client Tool** and select it.
3. Set the **MCP Endpoint URL** to the endpoint from the table above.
4. No authentication is required — these servers are internal to the workshop environment.
5. Connect the node → Agent's **Tools** input.
6. Repeat for all three new servers.

### Update the System Prompt

Open the AI Agent node and update the Role section to list all 5 tools:

```
You are a concise, factual network engineering assistant with access to these MCP Servers:

* Meraki (Campus Network Management Platform)
* Nexus (Data Center switching management)
* Intersight (Infrastructure device management for Cisco UCS systems)
* ITSM (IT Service Management for change control and incident tracking)

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

---

## Exercises

### Exercise 1 — Compare Qwen vs. OpenAI on the same question

Ask the same question twice — first with Qwen active, then swap the LLM connection to the OpenAI node and ask again:

```
What clients are connected to the Meraki network? Summarize in 3 bullet points.
```

Observe differences in:

- Response time
- Formatting style
- Level of detail
- Whether it stays within your system prompt rules

### Exercise 2 — Query the Nexus data center

```
What VLANs are configured on the Nexus switches?
```

```
Show me the network topology — which devices are connected to which?
```

```
What is the status of the interfaces on the core switch?
```

### Exercise 3 — Query Intersight compute

```
What servers are managed in Intersight?
```

```
Are any UCS servers running outdated firmware?
```

```
Are there any hardware health alerts for my servers?
```

### Exercise 4 — Query the ITSM system

```
Are there any open incidents right now?
```

```
Is there a change request scheduled for this week?
```

```
Search the knowledge base for documentation on VLAN configuration.
```

### Exercise 5 — Cross-domain correlation (the full power)

This is where having 5 connected domains pays off. Try:

```
A user is reporting slow application performance. Check Meraki for network problems, Nexus for any data center connectivity issues, and ITSM for any related incidents or scheduled changes.
```

Watch the agent orchestrate calls across multiple MCP servers and synthesize a correlated answer — something that would take a human engineer 20–30 minutes to do manually.

### Exercise 6 — A/B test cloud vs. on-prem LLM

1. Ask a complex cross-domain question with Qwen active. Note the response time and quality.
2. Disconnect Qwen from the agent's LLM input.
3. Connect the OpenAI Chat Model node to the agent's LLM input.
4. Ask the same question.
5. Discuss: for this type of structured, tool-based network ops query, how much quality difference is there? Is the privacy benefit of Qwen worth the capability tradeoff?

---

## Why More Tools is a Double-Edged Sword

You now have 5 MCP servers connected. This provides enormous capability, but also increases:

- **Token usage:** every tool's description is sent to the LLM on every turn
- **Latency:** more tools to evaluate before responding
- **Error surface:** more tools = more chances to call the wrong one

This is especially pronounced with smaller on-prem models. Mitigation strategies:

- Write a very tight, directive system prompt
- Use `include` filtering in each MCP client to expose only the tools you actually need
- Consider breaking into multiple specialized agents (a Meraki agent, a data center agent, etc.) with a routing layer

---

## MCP Server Availability in Lab vs. Production

The Nexus, Intersight, and ITSM endpoints use Kubernetes internal DNS (`svc.cluster.local`). They are only reachable from within the lab cluster. If you are running N8N outside the cluster or in your own environment:

- Replace with your organization's actual MCP server URLs
- These MCP servers can be self-hosted or SaaS-based — the N8N MCP Client node works the same either way
- See each platform's documentation for how to deploy or connect to their MCP server

---

## Key Takeaways

- On-prem LLMs provide data privacy at the cost of context window size and response speed.
- For focused, tool-augmented agents, smaller models (7B–13B parameters) perform well when the system prompt is tight.
- N8N's OpenAI-compatible node works with any inference server — vLLM, Ollama, llama.cpp, LM Studio.
- Five MCP servers gives the agent cross-domain visibility that previously required multiple human specialists.
- Context window is now the main bottleneck — large tool response payloads can overflow a smaller model's window.

---

## What You Have Built

Over four steps, you have transformed a simple weather chatbot into a full-stack network operations AI agent:

```
Step 1: Weather + News bot (explore agentic concepts)
Step 2: + Meraki MCP + network engineer persona (understand MCP and personas)
Step 3: - Weather tool (understand focused toolsets)
Step 4: Qwen on-prem LLM + Nexus + Intersight + ITSM (privacy + full visibility)
```

---

## Next Step

For an optional deep-dive into ThousandEyes endpoint monitoring, proceed to [Step 5](../step5/Step5-README.md) — a focused ThousandEyes-only exercise.