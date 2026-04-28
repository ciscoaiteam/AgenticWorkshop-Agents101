#!/usr/bin/env zsh
# =============================================================================
# MCP Scanner — Quick Start
# https://github.com/cisco-ai-defense/mcp-scanner
#
# Scans an MCP server for security findings using YARA rules (no API key needed).
# =============================================================================

MCP_SERVER="https://selent-mcp-selent-mcp.apps.rcdnailab01.ciscoailabs.com/mcp"

# ── Step 1: Install mcp-scanner (skip if already installed) ──────────────────
if ! command -v mcp-scanner &>/dev/null; then
  echo "Installing mcp-scanner..."
  uv tool install --python 3.13 cisco-ai-mcp-scanner
fi

# ── Step 2: Scan the MCP server ───────────────────────────────────────────────
echo "Scanning: $MCP_SERVER"
echo ""

mcp-scanner \
  --analyzers yara \
  --format    summary \
  remote \
  --server-url "$MCP_SERVER"
