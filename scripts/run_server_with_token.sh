#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${HTTP_BEARER_TOKEN:-}" ]]; then
  if [[ -f .env ]]; then
    HTTP_BEARER_TOKEN=$(grep -E '^HTTP_BEARER_TOKEN=' .env | sed -E 's/^HTTP_BEARER_TOKEN=//') || true
  fi
fi
if [[ -z "${HTTP_BEARER_TOKEN:-}" ]]; then
  if command -v uv >/dev/null 2>&1; then
    HTTP_BEARER_TOKEN=$(uv run python - <<'PY'
import secrets; print(secrets.token_hex(32))
PY
)
  else
    HTTP_BEARER_TOKEN="$(date +%s)_$(hostname)"
  fi
fi
export HTTP_BEARER_TOKEN

PYTHON_BIN="${AGENT_MAIL_PYTHON:-}"
if [[ -z "${PYTHON_BIN}" && -x ".venv/bin/python" ]]; then
  PYTHON_BIN=".venv/bin/python"
fi

if [[ -n "${PYTHON_BIN}" ]]; then
  exec "${PYTHON_BIN}" -m mcp_agent_mail.cli serve-http "$@"
fi

exec uv run python -m mcp_agent_mail.cli serve-http "$@"
