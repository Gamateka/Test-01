# Accesso MCP a Canva e Higgsfield dal server Hetzner

Script per rendere Canva e Higgsfield raggiungibili e utilizzabili come server
MCP dalla macchina Hetzner che ospita Microgames.

## Perche' esiste

Da una verifica dell'infrastruttura risulta che:

- `microgames.dev`, `www.microgames.dev` e `pannello.microgames.dev` puntano
  tutti a `178.105.21.154` — AS24940, Hetzner Online GmbH (Germania).
- I record DNS sono su Cloudflare con `proxied: false`: Cloudflare fa solo da
  name server, il traffico non passa dalla sua rete.
- Su quel server non e' installato nessun connettore MCP. I connettori
  WordPress esistenti puntano ad altre macchine (Netsons, Aruba, Hostinger),
  quindi nessuno di essi da' accesso alla macchina Microgames.

Di conseguenza la configurazione va fatta **sul server**, e questi script la
riducono a due comandi.

## Prerequisiti

- Accesso SSH al server Hetzner.
- `curl` e `bash` (presenti su qualsiasi installazione standard).
- La CLI di Claude Code installata sul server, se vuoi il passo 2.
  Serve solo per registrare i server MCP; il passo 1 funziona comunque.

## Uso

Copia questa cartella sul server, poi:

```bash
cd hetzner-mcp
cp .env.example .env && chmod 600 .env
$EDITOR .env          # compila gli URL: dove trovarli e scritto nel file

./01-check-egress.sh  # la rete raggiunge Canva e Higgsfield?
./02-add-mcp-servers.sh
```

Esegui **sempre prima** `01-check-egress.sh`. I server MCP parlano HTTPS verso
gli stessi domini delle API: se l'egress e' bloccato, registrarli non risolve
niente e produce un errore molto meno leggibile.

Per vedere cosa farebbe il secondo script senza applicare nulla:

```bash
./02-add-mcp-servers.sh --dry-run
```

## Come si legge l'esito del test di egress

| Risultato | Significato | Cosa fare |
|---|---|---|
| `HTTP 401` / `403` | **La rete funziona.** L'endpoint risponde e rifiuta la richiesta perche' non autenticata. | Problema di credenziali o scope, non di connettivita'. |
| `HTTP 200` | Rete e endpoint a posto. | Se l'app fallisce lo stesso, guarda la sua configurazione. |
| `HTTP 000` + TCP mai stabilito | Connessione bloccata in uscita. | Cloud Firewall Hetzner, poi firewall locale. |
| `HTTP 000` + TCP ok, TLS no | Handshake interrotto. | Ispezione TLS, proxy intermedio o reset. |
| DNS fallito | Il nome non si risolve. | Resolver del server (`/etc/resolv.conf`). |

Il punto meno intuitivo: **un 401 e' una buona notizia.** Significa che il
pacchetto ha attraversato tutta la catena di rete ed e' arrivato al servizio.

Su Hetzner Cloud il blocco piu' frequente non e' `iptables` ma il **Cloud
Firewall**, che si configura in `console.hetzner.cloud` e non compare in
nessun comando eseguito sulla macchina. Lo script lo ricorda ma non puo'
verificarlo da solo.

## Autenticazione su una macchina headless

I server MCP in OAuth aprono un browser per il consenso. Su un server senza
interfaccia grafica ci sono due strade:

**Bearer token statico.** Se il servizio ne rilascia uno, mettilo in `.env`
(`CANVA_MCP_TOKEN`, `HIGGSFIELD_MCP_TOKEN`): lo script lo passa come header
`Authorization` e il flusso interattivo non serve.

**Port forwarding SSH.** Ti colleghi inoltrando la porta del callback OAuth,
cosi' il browser del tuo computer completa il flusso avviato sul server:

```bash
ssh -L 54545:localhost:54545 utente@178.105.21.154
# poi, nella sessione remota:
claude
/mcp
```

La porta esatta la indica Claude Code quando avvia il flusso: adatta il numero
a quello che vedi a schermo.

## Nota importante: MCP non e' la strada per l'applicazione

Va distinto **chi** deve accedere a Canva e Higgsfield.

- Se e' **Claude Code sul server** — questi script sono la strada giusta.
- Se e' **l'applicazione Microgames** — MCP non e' il livello corretto. I
  server MCP servono a dare strumenti a un client AI; un'applicazione va
  invece sulle **REST API** dei due servizi, con le proprie chiavi. Registrare
  i server MCP non renderebbe le API disponibili al codice dell'app.

In quel secondo caso resta comunque utile `01-check-egress.sh`: verifica la
connettivita' di rete, che e' un prerequisito di entrambi gli approcci.

## Da verificare a parte

Se l'applicazione usa lo stesso account Higgsfield collegato a claude.ai, il
piano risulta **starter con 14 crediti residui**. Con crediti esauriti una
chiamata di generazione fallisce con un errore che somiglia molto a un
problema di accesso, pur essendo di quota.
