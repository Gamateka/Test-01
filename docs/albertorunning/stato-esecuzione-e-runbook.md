# Stato esecuzione — 7 settembre 2026

## In sintesi

**Nessuno dei cinque punti e' stato eseguito sul sito.** Il connettore MCP di
Alberto Running risulta installato ma **disconnesso**: non espone alcun tool in
sessione, quindi il sito non e' raggiungibile ne' in scrittura ne' in lettura.

Va riautorizzato. Fatto quello, i punti 1-4 sono meccanici (runbook piu' sotto)
e il punto 5 e' gia' fatto a meta': il lato listino e' stato ricostruito e
documentato in `listino-prezzi-verifica.md`, manca solo il confronto con quanto
e' pubblicato.

## Cosa e' stato verificato

### Il connettore e' installato ma da riautorizzare

`ListConnectors` restituisce la voce, in stato di riconnessione richiesta:

```json
{
  "name": "Alberto Running",
  "installState": "needs_reconnect",
  "connected": false,
  "enabledInChat": false
}
```

Questo e' un progresso rispetto alla sessione precedente, che aveva registrato
il connettore come **assente** (vedi `README.md`, sezione "Perche' questo
pacchetto esiste come file"). Ora c'e': e' solo scaduto o revocato.

Sono invece attivi e rispondono altri quattro connettori WordPress:

| Connettore | Sito | Risponde |
|---|---|---|
| Fabio Cioni | fabiocioni.it | si |
| Sempoint | sempoint.it | si |
| SmartLands GIS | smartlands-gis.com | si |
| MyNutritional | (studio nutrizionale) | si |

Nessuno di questi e' albertorunning.it. **Non vanno usati come ripiego**: sono
siti diversi, e applicarci sopra il pacchetto farebbe un danno.

### Nemmeno la lettura via HTTP e' possibile

L'egress di rete dell'ambiente e' filtrato e il dominio non e' in lista:

```
curl https://albertorunning.it/      -> CONNECT tunnel failed, response 403
curl https://www.albertorunning.it/  -> CONNECT tunnel failed, response 403
```

Quindi non c'e' nemmeno la via di ripiego "leggo la pagina pubblica per
controllare i prezzi". Il punto 5 resta a meta' per questo motivo.

### Come si sblocca

Su claude.ai: **Impostazioni -> Connettori -> "Alberto Running" -> riconnetti**
e ripeti l'autorizzazione. Poi va verificato che il connettore sia **abilitato
in chat** per la sessione (`enabledInChat` deve diventare `true`), altrimenti
i tool restano comunque fuori.

Se dopo la riconnessione i tool non compaiono, il problema e' lato sito: il
plugin EMCP Tools potrebbe essere disattivato, o la chiave dell'endpoint MCP
rigenerata.

## Versioni: quello che si sa senza connettore

Le notifiche automatiche inviate da `wordpress@albertorunning.it` a
`info@fabiocioni.it` danno un'istantanea, ma **datata**. Da riverificare sul
posto, non e' materiale su cui decidere:

| Dato | Valore | Fonte | Data |
|---|---|---|---|
| WordPress | 6.9.3 | mail "Il tuo sito e' aggiornato a WordPress 6.9.3" | 11/03/2026 |
| Elementor | 4.1.1 | mail di aggiornamento automatico plugin | 27/05/2026 |
| PHP | ignoto | — | — |
| Elementor Pro | ignoto | — | — |
| EMCP Tools | ignoto | — | — |

Due cose che saltano all'occhio:

1. **Le notifiche si fermano al 27/05/2026.** Da oltre tre mesi non arriva piu'
   nulla. O gli aggiornamenti automatici sono fermi, o le mail non partono piu'.
   Vale la pena guardarci: un sito che non aggiorna piu' e un connettore che
   chiede di riautenticarsi possono avere la stessa causa a monte. Da notare che
   il 03/03/2026 era gia' arrivata una mail "L'aggiornamento di alcuni plugin
   e' fallito".
2. **Il sito e' indietro rispetto agli altri.** Gli altri quattro siti gestiti
   sono su WordPress 7.1 ed Elementor 4.2.x; qui l'ultimo dato utile e'
   WordPress 6.9.3 ed Elementor 4.1.1.

### EMCP Tools: la versione citata e' corretta

Verificato su fabiocioni.it (lettura, nessuna modifica):

```json
{"slug":"emcp-tools","name":"EMCP Tools","version":"3.7.0",
 "update_available":true,"new_version":"3.15.0","is_protected":true}
```

Quindi 3.7.0 installata e 3.15.0 disponibile: il salto da fare e' quello. Su
albertorunning.it la versione va comunque letta dal sito, non data per scontata.

Nota operativa: EMCP Tools e' un plugin `is_protected`, non disattivabile via
MCP. L'aggiornamento e' possibile (`emcp-tools-update-plugin`), ma aggiorna il
plugin che fornisce il canale che si sta usando: se qualcosa va storto a meta',
si perde il connettore. Meglio farlo come **prima** operazione della sessione,
non in mezzo al lavoro, e riverificare subito dopo con `core-get-site-info`.

## Runbook: punti 1-4 a connettore riattivato

I nomi dei tool sono quelli standard del set EMCP; vanno confermati alla
riconnessione, perche' variano leggermente da un'installazione all'altra
(alcuni siti espongono anche `get-page-html`, `find-broken-links`, altri no).

### Punto 1 — Diagnostica e aggiornamento

1. `core-get-site-info` — conferma che il connettore punta davvero a
   `https://albertorunning.it` e non ad altro.
2. `core-get-environment-info` — versione PHP, versione WordPress, DB.
3. `emcp-tools-detect-elementor-version` — Elementor e Elementor Pro.
4. `emcp-tools-list-plugins` — quadro completo, incluso EMCP Tools e quali
   plugin hanno `update_available: true`.
5. Se EMCP Tools e' < 3.15.0: `emcp-tools-update-plugin` (slug `emcp-tools`),
   poi **subito** `core-get-site-info` per verificare che il canale regga.

Da riportare: versioni prima/dopo, e la lista degli altri aggiornamenti
arretrati (probabilmente parecchi, viste le notifiche ferme da maggio).

### Punto 2 — Pagina `/grazie-prova-gratuita/`

**Prima leggere i colori reali del sito**, che e' il pezzo mancante:

1. `emcp-tools-get-global-settings` — restituisce i colori globali Elementor.
2. Sostituire le sei variabili in testa a `thankyou-page.html`, che sono
   segnaposto dichiarati (`/* >>> Sostituire con i colori reali del sito <<< */`):

   | Variabile | Segnaposto | Va sostituito con |
   |---|---|---|
   | `--ar-scuro` | `#12212e` | colore testo/titoli del sito |
   | `--ar-accento` | `#0f8a5f` | colore primario del sito |
   | `--ar-accento-chiaro` | `#e8f5ef` | versione tenue del primario |
   | `--ar-grigio` | `#5b6b78` | colore testo secondario |
   | `--ar-bordo` | `#e2e8ed` | colore bordi/divisori |
   | `--ar-sfondo` | `#f7f9fa` | sfondo dei box |

   Gli stessi sei valori vanno riportati anche in
   `email/01-conferma-iscrizione.html`, che usa la stessa palette.

3. `emcp-tools-create-page` con slug `grazie-prova-gratuita`, contenuto
   `thankyou-page.html` (widget HTML a piena larghezza, contenitore senza
   padding — il CSS e' tutto sotto il prefisso `.ar-ty` e non tocca il tema).
4. **noindex.** Prima va visto quale plugin SEO c'e' (`emcp-tools-list-plugins`):
   con Rank Math e' il meta `rank_math_robots`, con Yoast
   `_yoast_wpseo_meta-robots-noindex`. Impostabile via
   `emcp-tools-update-page-settings` o, se non passa, via `emcp-tools-run-wp-cli`.
   Poi **verificare davvero** che l'HTML servito contenga il meta noindex:
   e' la pagina che espone l'IBAN, darlo per fatto senza controllare non basta.
5. Escludere la pagina dalla sitemap del plugin SEO.

### Punto 3 — Modulo prova gratuita

1. `emcp-tools-list-pages` + `emcp-tools-find-element` per individuare il widget
   `form` della prova gratuita e il suo `element_id`.
2. `emcp-tools-get-element-settings` sul widget: serve a leggere gli **id reali
   dei campi**, che potrebbero non coincidere con quelli ipotizzati in
   `configurazione-elementor-form.md` (`nome`, `email`, `piano`, ...). Gli
   shortcode `[field id="..."]` nelle email vanno allineati a quelli veri,
   altrimenti le mail arrivano con i campi vuoti.
3. `emcp-tools-update-element` per impostare, in quest'ordine, le tre azioni
   dopo l'invio: **Email** (notifica interna), **Email 2** (autorisponditore),
   **Redirect**. I contenuti sono in `email/00-notifica-admin.txt`,
   `email/01-conferma-iscrizione.html` e il redirect punta a
   `/grazie-prova-gratuita/`. Dettaglio completo in
   `configurazione-elementor-form.md`.
4. Invio di prova reale, con controllo della cartella spam. La deliverability e'
   il punto piu' fragile del flusso ed e' gia' segnalata come tale nel pacchetto.

### Punto 4 — Sicurezza e performance

1. `emcp-tools-scan-security`
2. `emcp-tools-analyze-performance`

Entrambi in sola lettura. Vanno riportati i risultati cosi' come escono, senza
correggere nulla di iniziativa: alcune voci tipiche di questi report (permessi
file, utenti, versioni esposte) toccano cose che vanno decise, non sistemate
d'ufficio.

## Una dipendenza da non ignorare: il punto 2 dipende dal punto 5

`thankyou-page.html` **non** cita importi come segnaposto: li ha scritti dentro,
alle righe 202 e 204, tutti e otto:

```html
<td>50 &euro;</td><td>140 &euro;</td><td>260 &euro;</td><td>490 &euro;</td>
<td>65 &euro;</td><td>165 &euro;</td><td>335 &euro;</td><td>655 &euro;</td>
```

Sono i prezzi del **listino PDF**. Ma la richiesta di Alberto del 03/07/2026 era
di allineare il listino ai prezzi **del sito**, non il contrario (dettaglio in
`listino-prezzi-verifica.md`).

Quindi: pubblicare la pagina prima di aver chiuso il punto 5 significa mettere
online, sulla stessa pagina che espone l'IBAN, un prezzario che potrebbe essere
quello sbagliato. **Il punto 5 va chiuso prima del punto 2**, o quantomeno la
tabella prezzi va tolta dalla pagina finche' la questione non e' decisa.

Le email invece sono a posto su questo fronte: `02-fine-prova-pagamento` usa il
segnaposto `[importo]`, non un valore fisso.
