#!/usr/bin/env bash
#
# 02-add-mcp-servers.sh — registra Canva e Higgsfield come server MCP nella
# Claude Code CLI installata sul server Hetzner.
#
# Prerequisito: 01-check-egress.sh deve passare. Se il server non raggiunge
# gli endpoint in HTTPS, registrarli non serve a niente.
#
# Uso:
#   cp .env.example .env && chmod 600 .env   # compila gli URL
#   ./02-add-mcp-servers.sh                  # registra entrambi
#   ./02-add-mcp-servers.sh --dry-run        # mostra i comandi senza eseguirli
#
# Idempotente: se un server con lo stesso nome esiste gia, viene saltato.

set -uo pipefail

cd "$(dirname "$0")"

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

if [ ! -f .env ]; then
    printf 'Manca il file .env.\n' >&2
    printf 'Crealo con: cp .env.example .env && chmod 600 .env\n' >&2
    exit 2
fi
# shellcheck disable=SC1091
. ./.env

MCP_SCOPE="${MCP_SCOPE:-user}"

if ! command -v claude >/dev/null 2>&1; then
    printf 'La CLI "claude" non e installata su questa macchina.\n' >&2
    printf 'Installala prima (vedi README, sezione Prerequisiti), poi rilancia.\n' >&2
    exit 2
fi

printf 'Claude Code: %s\n' "$(claude --version 2>/dev/null || echo 'versione non determinata')"
printf 'Scope      : %s\n\n' "$MCP_SCOPE"

existing="$(claude mcp list 2>/dev/null || true)"

# printf tratterebbe una stringa che inizia per "--" come opzione: va passata
# come argomento di %s, non come formato.
hr() { printf '%s\n' "------------------------------------------------------------"; }

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        printf '  [dry-run] %s\n' "$*"
        return 0
    fi
    "$@"
}

# add_server <nome> <url> <token>
add_server() {
    local name="$1" url="$2" token="${3:-}"

    printf '== %s\n' "$name"

    if [ -z "$url" ]; then
        printf '   SALTATO: URL non compilato in .env\n'
        printf '   Recuperalo da claude.ai -> Impostazioni -> Connettori\n\n'
        return 1
    fi

    if printf '%s' "$existing" | grep -qi "^${name}[[:space:]:]"; then
        printf '   Gia registrato. Per sostituirlo: claude mcp remove %s\n\n' "$name"
        return 0
    fi

    # Pre-flight: un endpoint MCP valido risponde qualcosa (spesso 401 o 400
    # senza sessione). Il codice 000 significa irraggiungibile.
    local code
    code="$(curl -sS -o /dev/null -w '%{http_code}' --max-time 15 "$url" 2>/dev/null || echo 000)"
    if [ "$code" = "000" ]; then
        printf '   ERRORE: %s non risponde (nessuna connessione).\n' "$url"
        printf '   Rilancia 01-check-egress.sh prima di insistere qui.\n\n'
        return 1
    fi
    printf '   Pre-flight: HTTP %s — endpoint raggiungibile\n' "$code"

    if [ -n "$token" ]; then
        printf '   Auth: bearer token da .env\n'
        run claude mcp add --transport http "$name" "$url" \
            --scope "$MCP_SCOPE" \
            --header "Authorization: Bearer ${token}"
    else
        printf '   Auth: OAuth interattivo (da completare dopo, vedi sotto)\n'
        run claude mcp add --transport http "$name" "$url" --scope "$MCP_SCOPE"
    fi

    local rc=$?
    if [ "$rc" -ne 0 ]; then
        printf '   Registrazione fallita (exit %s).\n\n' "$rc"
    elif [ "$DRY_RUN" -eq 1 ]; then
        printf '   (dry-run: nessuna modifica applicata)\n\n'
    else
        printf '   Registrato.\n\n'
    fi
    return "$rc"
}

errors=0
add_server canva      "${CANVA_MCP_URL:-}"      "${CANVA_MCP_TOKEN:-}"      || errors=$((errors + 1))
add_server higgsfield "${HIGGSFIELD_MCP_URL:-}" "${HIGGSFIELD_MCP_TOKEN:-}" || errors=$((errors + 1))

hr
printf 'Server MCP registrati:\n'
if [ "$DRY_RUN" -eq 1 ]; then
    printf '  (dry-run: nessuna modifica applicata)\n'
else
    claude mcp list 2>/dev/null || printf '  impossibile elencare\n'
fi
hr

if [ "$errors" -gt 0 ]; then
    printf '\n%s server non registrati. Vedi i messaggi sopra.\n' "$errors"
    exit 1
fi

cat <<'EOF'

Ultimo passo, per i server in OAuth:

  1. avvia la CLI:            claude
  2. dentro la sessione:      /mcp
  3. scegli il server e completa l autenticazione

Su una macchina headless il browser non si apre: il README spiega come
gestirlo nella sezione "Autenticazione su una macchina headless".
EOF
