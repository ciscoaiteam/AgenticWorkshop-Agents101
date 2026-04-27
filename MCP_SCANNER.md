# MCP Scanner

[MCP Scanner](https://github.com/cisco-ai-defense/mcp-scanner) is an open-source tool from Cisco AI Defense that scans MCP servers for security threats — including prompt injection, tool poisoning, and malicious tool descriptions.

## Install

Requires [uv](https://docs.astral.sh/uv/getting-started/installation/).

```bash
uv tool install --python 3.13 cisco-ai-mcp-scanner
```

## Scan an MCP Server (Lab Meraki MCP as example)

```bash
mcp-scanner --analyzers yara --format summary remote \
  --server-url https://selent-mcp-selent-mcp.apps.rcdnailab01.ciscoailabs.com/mcp
```

Or use the included script:

```bash
./scan-mcps.sh
```

## Analyzers


| Analyzer | Requires                  | What it detects                                               |
| -------- | ------------------------- | ------------------------------------------------------------- |
| `yara`   | Nothing                   | Pattern-based threats (prompt injection, suspicious commands) |
| `llm`    | `MCP_SCANNER_LLM_API_KEY` | Semantic threats using an LLM as judge                        |
| `api`    | `MCP_SCANNER_API_KEY`     | Cisco AI Defense cloud analysis                               |


Use multiple analyzers together: `--analyzers yara,llm,api`

## Output Formats


| Format        | Description                               |
| ------------- | ----------------------------------------- |
| `summary`     | Pass/fail count with unsafe items listed  |
| `table`       | One row per tool with severity columns    |
| `detailed`    | Full findings breakdown per tool          |
| `by_severity` | Results grouped by HIGH / MEDIUM / LOW    |
| `raw`         | Raw JSON (good for piping to other tools) |


## Examples

```bash
# Scan with detailed output
mcp-scanner --analyzers yara --format detailed remote --server-url <URL>

# Scan a server that requires a Bearer token
mcp-scanner --analyzers yara --format summary remote \
  --server-url <URL> --bearer-token "$TOKEN"

# Scan all MCP servers defined in your Cursor config
mcp-scanner --analyzers yara --format summary known-configs

# Scan a local/stdio MCP server
mcp-scanner --analyzers yara --format summary \
  stdio --stdio-command uvx --stdio-arg mcp-server-fetch
```

