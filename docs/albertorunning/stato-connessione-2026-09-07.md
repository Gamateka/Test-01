# Perche' il connettore non si collega — 7 settembre 2026

Aggiorna `stato-esecuzione-e-runbook.md` (PR #4) e ne **corregge due conclusioni
sbagliate**. Quel documento, non potendo leggere il sito, aveva dedotto dalle
vecchie mail che albertorunning.it fosse rimasto indietro e sospettava un
plugin MCP rotto. La schermata di wp-admin del 07/09/2026 dice il contrario.

## Il punto in una riga

Il sito sta benissimo e il suo server MCP e' acceso. Quello che manca e' **il
sign-in OAuth**: il client e' registrato ma non ha mai completato
l'autorizzazione. Il consenso dato su claude.ai non c'entra — e' un'altra
registrazione, e sul sito non risulta affatto.

## Cosa dice davvero wp-admin

Da `EMCP Tools -> Connection`, il 07/09/2026:

| Voce | Stato |
|---|---|
| MCP Tools for Elementor | **Active** |
| MCP Adapter (bundled) | **Active** |
| MCP Server | **Enabled** |
| Tools Enabled | **181 / 266** |
| EMCP Tools | **v3.15.0** |
| WordPress | **7.1** |
| Server URL | `https://albertorunning.it` (auto-rilevato) |
| OAuth sign-in for AI clients | **attivo** |

Endpoint: `https://albertorunning.it/wp-json/mcp/emcp-tools-server`

### Le due correzioni a PR #4

1. **Il sito non e' indietro.** PR #4 riportava WordPress 6.9.3 (dato di marzo)
   ed Elementor 4.1.1 (dato di maggio), ricostruiti dalle notifiche automatiche,
   e concludeva che albertorunning.it fosse rimasto dietro agli altri quattro
   siti gestiti. E' su **WordPress 7.1**, come gli altri. Le notifiche mail
   ferme al 27/05/2026 non significavano sito fermo: significavano solo mail
   che non partono piu'.
2. **EMCP Tools e' gia' aggiornato.** Il runbook faceva iniziare il punto 1 con
   l'aggiornamento del plugin da 3.7.0 a 3.15.0, con tutta la cautela del caso
   (`is_protected`, si aggiorna il canale che si sta usando). **Quel passo
   non serve**: 3.15.0 e' gia' installata. Il 3.7.0 era la versione di
   fabiocioni.it, non di questo sito.

Cade quindi anche il sospetto "EMCP Tools disattivato o rotto": e' attivo,
aggiornato, e serve 181 tool.

## La causa vera: OAuth mai completato

`Manage connected apps` elenca **una sola** app registrata:

| Client | Status | Connected as | Registered |
|---|---|---|---|
| `Claude Code (emcp-albertorunning-it)` | **Never signed in** | — | 7 Settembre 2026 |

callback: `http://localhost:3118/callback`

Due cose si leggono qui dentro.

### 1. Il client c'e', la firma no

La registrazione e' di oggi: e' l'effetto del `claude mcp add` lanciato sul
Mac. Ma `Never signed in` vuol dire che il passo b della procedura EMCP — *"The
next time your AI client connects, your browser opens so you can authorize
it"* — **non e' mai stato portato a termine**. Registrare il client e
autorizzarlo sono due passaggi distinti; e' stato fatto solo il primo.

Il rimedio e' sul Mac, non su claude.ai: avviare `claude` nel terminale, farlo
connettere, e **approvare nella finestra del browser che si apre**. Dopo,
`Connected as` deve riportare l'utente admin al posto del trattino.

### 2. claude.ai non e' registrato sul sito

Se il connettore claude.ai "Alberto Running" avesse una registrazione valida,
comparirebbe come **seconda riga** in quella tabella. Non c'e'. Ecco perche'
`ListConnectors` continua a rispondere:

```json
{"name":"Alberto Running","installState":"needs_reconnect",
 "connected":false,"enabledInChat":false}
```

Il consenso viene ridato su claude.ai, ma sul sito non atterra nessuna
registrazione: e' un'autorizzazione che gira a vuoto. Ridarlo una quinta volta
non cambiera' nulla. Va **rimosso e reinstallato** il connettore su claude.ai,
cosi' che rifaccia la registrazione da zero — la scheda "Claude.ai" sotto
*Connect Your AI Client* nella stessa pagina EMCP da' i passi esatti.

## Da questa sessione resta comunque impossibile

Indipendentemente dall'OAuth, questa sessione gira **in un container cloud**,
non sul Mac, e la sua policy di rete vieta l'uscita verso il dominio:

```
https://albertorunning.it/                              -> CONNECT tunnel failed, 403
https://www.albertorunning.it/                          -> CONNECT tunnel failed, 403
https://albertorunning.it/wp-json/mcp/emcp-tools-server  -> CONNECT tunnel failed, 403
```

```
2026-09-07T16:58:58Z  albertorunning.it:443  connect_rejected
2026-09-07T17:00:51Z  albertorunning.it:443  connect_rejected
2026-09-07T17:01:11Z  albertorunning.it:443  connect_rejected  (x2)
```

`gateway answered 403 to CONNECT (policy denial)`. Le due righe delle 17:01:11
sono l'health check del `claude mcp add` eseguito qui: il client non ha mai
raggiunto il server, quindi il suo `! Needs authentication` e' un ripiego, non
una risposta del sito.

Verificata e scartata anche la via WordPress.com/Jetpack: i siti collegati sono
`pasempoli.it`, `fabiocioni.it/store`, `trancerialastella.it`. albertorunning.it
non e' fra questi.

| | Claude Code sul Mac | Questa sessione |
|---|---|---|
| Macchina | MacBookAir | container cloud (`vm`, Linux) |
| Config MCP | `emcp-albertorunning-it` gia' presente | aggiunta ora, inutilizzabile |
| Rete verso il dominio | nessun filtro | **vietata da policy** |
| Cosa manca | **solo il sign-in OAuth** | sblocco di rete + OAuth |

**La strada piu' corta e' il Mac**: completato il sign-in, il runbook di PR #4
e' eseguibile subito. Per lavorare da qui servirebbe invece aggiungere
`albertorunning.it` agli host consentiti nella policy di rete dell'ambiente
remoto (si sceglie alla creazione dell'ambiente —
https://code.claude.com/docs/en/claude-code-on-the-web).

## Due cose emerse dalla schermata, che valgono per il runbook

### Il plugin SEO e' Yoast

Il runbook, al punto 2, lasciava aperta la forcella: *"con Rank Math e' il meta
`rank_math_robots`, con Yoast `_yoast_wpseo_meta-robots-noindex`"*. Nella barra
laterale di wp-admin c'e' **Yoast SEO** (con 2 notifiche). Quindi per il
noindex della pagina `/grazie-prova-gratuita/` vale
`_yoast_wpseo_meta-robots-noindex`, e la sitemap da cui escluderla e' quella di
Yoast. Un ramo in meno da decidere sul posto.

### Un avviso di object cache da guardare

In cima a wp-admin:

```
Can NOT find LSCWP path for object cache initialization in
/home/jsbmcqen/albertorunning.it/wp-content/object-cache.php
```

LiteSpeed Cache non riesce a inizializzare l'object cache. Non blocca niente di
quanto sopra, ma e' il tipo di cosa che rientra nel punto 4 (performance) ed e'
gia' visibile senza bisogno di scansioni.

## Materiale nuovo, non coperto da PR #3 e PR #4

Recuperato dalla posta. Nessuno di questi elementi compare nei due pacchetti.

### Logo: richiesta di Alberto rimasta in sospeso (25/07/2026)

Alberto scrive (`nuovo logo`, allegato `Immagine1.png`):

> Ho ideato questo nuovo logo. Dimmi se ti piace e se si, se possiamo metterlo
> come logo ufficiale ovunque.

Fabio ha risposto il **27/07/2026** che cosi' com'e' non si presta a logo
ufficiale, spiegando i motivi. **La questione non risulta chiusa.** Rileva
perche' "ovunque" include il sito, e quindi tocca la pagina
`/grazie-prova-gratuita/` e le email di PR #3 quando verranno pubblicate.

### Scheda di allenamento (15/07/2026)

Allegato `Piano_Allenamento_Alberto_Running.docx`, mail `scheda allenamento`,
che fa seguito a `Fac simile tabella` del 17/06/2026. E' il materiale delle
tabelle consegnate ai clienti, lo stesso oggetto dell'evento di calendario del
29/06/2026 "Aggiornare schede e sito Alberto Running". Non ancora valutato in
nessuna delle due PR.

### Coordinate di pagamento: confermate, nessuna azione

La mail `iban` del **01/09/2026** da `info@albertorunning.it` (Banca Widiba,
intestatario Alberto Biscardi) **coincide** con quanto gia' scritto nel
pacchetto di PR #3 e con la pagina 2 del listino PDF. Nulla da correggere.

## Cosa resta valido di PR #4

Il resto del runbook regge: punti 2, 3, 4 e 5 invariati, meno il passo di
aggiornamento del plugin (non piu' necessario) e la forcella SEO (risolta:
Yoast). Resta in piedi soprattutto la dipendenza principale:

> **Il punto 5 (prezzi) va chiuso prima del punto 2 (pagina di ringraziamento).**

`thankyou-page.html` porta gli otto importi scritti dentro, non come
segnaposto. Finche' non si leggono i prezzi davvero pubblicati sul sito,
pubblicare quella pagina significa mettere online un prezzario potenzialmente
sbagliato sulla stessa pagina che espone l'IBAN.

A connettore funzionante il punto 5 e' ora rapido: `emcp-tools-search-content`
sui singoli importi, si compila la colonna mancante e si porta la differenza ad
Alberto.
