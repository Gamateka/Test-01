#!/usr/bin/env bash
#
# 01-check-egress.sh — verifica che il server Hetzner raggiunga Canva e
# Higgsfield in uscita sulla 443.
#
# Va eseguito PRIMA di 02-add-mcp-servers.sh: se l'egress e' bloccato, anche
# la connessione MCP fallira', perche' parla HTTPS verso gli stessi domini.
#
# Uso:
#   ./01-check-egress.sh              # host dal file .env
#   ./01-check-egress.sh URL [URL...] # host indicati a mano
#
# Non modifica nulla: solo lettura e diagnostica.

set -uo pipefail

cd "$(dirname "$0")"

if [ -f .env ]; then
    # shellcheck disable=SC1091
    . ./.env
fi

TIMEOUT=15
failures=0
blocked=0

hr() { printf '%s\n' "------------------------------------------------------------"; }

# Confronto numerico robusto: curl stampa "0", "0.000000" o "0,000000"
# a seconda della locale.
is_zero() {
    awk -v v="$(printf '%s' "$1" | tr ',' '.')" 'BEGIN { exit !(v + 0 == 0) }'
}

# Estrae l'hostname da un URL, senza dipendere da tool esterni.
host_of() {
    printf '%s' "$1" | sed -E 's#^[a-zA-Z][a-zA-Z0-9+.-]*://##; s#[/?#].*$##; s#^[^@]*@##; s#:[0-9]+$##'
}

check_url() {
    local url="$1" host code namelookup connect appconnect
    host="$(host_of "$url")"

    printf '\n%s\n' "== $host"
    printf '   url: %s\n' "$url"

    # --- DNS ---
    if ! getent hosts "$host" >/dev/null 2>&1; then
        printf '   DNS  : FALLITO — %s non si risolve\n' "$host"
        printf '   causa: resolver del server (controlla /etc/resolv.conf)\n'
        failures=$((failures + 1))
        return
    fi
    printf '   DNS  : ok — %s\n' "$(getent hosts "$host" | awk '{print $1}' | paste -sd, -)"

    # --- HTTPS ---
    local fmt='%{http_code} %{time_namelookup} %{time_connect} %{time_appconnect}'
    local out
    out="$(curl -sS -o /dev/null -w "$fmt" --max-time "$TIMEOUT" "$url" 2>/dev/null)"
    read -r code namelookup connect appconnect <<<"$out"

    if [ "${code:-000}" = "000" ]; then
        printf '   HTTPS: FALLITO — nessuna risposta entro %ss\n' "$TIMEOUT"

        local proxy="${https_proxy:-${HTTPS_PROXY:-}}"
        if [ -n "$proxy" ]; then
            printf '   nota : proxy impostato nell ambiente (%s).\n' "$proxy"
            printf '          I tempi sotto misurano la connessione AL PROXY, non a\n'
            printf '          %s: il blocco puo essere il proxy stesso.\n' "$host"
        fi

        if is_zero "${connect:-0}"; then
            printf '   causa: connessione TCP mai stabilita → blocco in uscita sulla 443\n'
        elif is_zero "${appconnect:-0}"; then
            printf '   causa: TCP stabilito ma TLS mai completato → filtro, proxy o reset\n'
        else
            printf '   causa: TLS completato ma nessuna risposta → timeout applicativo\n'
        fi
        blocked=$((blocked + 1))
        failures=$((failures + 1))
        return
    fi

    printf '   HTTPS: HTTP %s (dns %ss, tcp %ss, tls %ss)\n' \
        "$code" "$namelookup" "$connect" "$appconnect"

    case "$code" in
        401|403)
            printf '   esito: RETE OK — risposta autenticata negata.\n'
            printf '          Il problema e la credenziale, non la connettivita.\n'
            ;;
        200|201|204|301|302|404|405)
            printf '   esito: RETE OK — il server risponde.\n'
            ;;
        5*)
            printf '   esito: rete ok, ma il servizio remoto risponde %s.\n' "$code"
            ;;
        *)
            printf '   esito: rete ok, codice inatteso %s.\n' "$code"
            ;;
    esac
}

hr
printf 'Test di egress — %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
printf 'host: %s\n' "$(hostname -f 2>/dev/null || hostname)"
hr

if [ "$#" -gt 0 ]; then
    targets=("$@")
else
    targets=()
    for v in "${CANVA_API_URL:-}" "${HIGGSFIELD_API_URL:-}" \
             "${CANVA_MCP_URL:-}" "${HIGGSFIELD_MCP_URL:-}"; do
        [ -n "$v" ] && targets+=("$v")
    done
fi

if [ "${#targets[@]}" -eq 0 ]; then
    printf 'Nessun endpoint da testare.\n' >&2
    printf 'Compila .env (cp .env.example .env) oppure passa gli URL come argomenti.\n' >&2
    exit 2
fi

for t in "${targets[@]}"; do
    check_url "$t"
done

# --- Contesto: firewall e container -----------------------------------------
printf '\n'
hr
printf 'Contesto\n'
hr

printf '\n-- Firewall locale in uscita --\n'
if command -v nft >/dev/null 2>&1 && nft list ruleset >/dev/null 2>&1; then
    if nft list ruleset 2>/dev/null | grep -qE 'chain output'; then
        nft list ruleset 2>/dev/null | sed -n '/chain output/,/}/p' | head -25
    else
        printf 'nftables: nessuna catena output definita.\n'
    fi
elif command -v iptables >/dev/null 2>&1; then
    iptables -S OUTPUT 2>/dev/null | head -20 || printf 'iptables: servono privilegi di root.\n'
else
    printf 'Nessun firewall locale rilevato (ne nft ne iptables).\n'
fi
printf '\nNOTA: su Hetzner Cloud il blocco puo stare anche nel Cloud Firewall,\n'
printf 'che non compare qui. Va verificato in console.hetzner.cloud.\n'

printf '\n-- Container --\n'
if command -v docker >/dev/null 2>&1 && docker ps >/dev/null 2>&1; then
    docker ps --format '  {{.Names}}  ({{.Image}})' 2>/dev/null | head -15
    printf '\nSe l applicazione gira in un container, il test va rifatto DENTRO:\n'
    printf '  docker exec <nome> curl -sS -o /dev/null -w "%%{http_code}\\n" %s\n' \
        "${CANVA_API_URL:-https://api.canva.com/rest/v1/users/me}"
else
    printf 'Docker non presente o non accessibile da questo utente.\n'
fi

# --- Verdetto ---------------------------------------------------------------
printf '\n'
hr
if [ "$failures" -eq 0 ]; then
    printf 'ESITO: tutti gli endpoint raggiungibili.\n'
    printf 'Se l applicazione fallisce lo stesso, la causa non e la rete:\n'
    printf 'guarda credenziali, scope OAuth e crediti residui del piano.\n'
    hr
    exit 0
fi

printf 'ESITO: %s endpoint su %s non raggiungibili.\n' "$failures" "${#targets[@]}"
if [ "$blocked" -gt 0 ]; then
    printf '\nCon connessioni bloccate, controlla in questo ordine:\n'
    printf '  1. Cloud Firewall Hetzner (console.hetzner.cloud) — regole in uscita\n'
    printf '  2. Firewall locale (output di cui sopra)\n'
    printf '  3. Proxy aziendale imposto via http_proxy/https_proxy\n'
    printf '  4. Se in container: rete del container, non dell host\n'
fi
hr
exit 1
