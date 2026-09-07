# Controllo generale del sito — da eseguire a connettore attivo

Elenco operativo di cio' che va verificato su albertorunning.it appena il
connettore MCP e' disponibile. L'ordine e' per impatto, non per comodita'.

## A. Verifica versioni e stato del connettore

Il primo punto e' la domanda posta esplicitamente: il sito e' aggiornato e il
connettore risponde meglio di prima?

- `core-get-environment-info` → versione WordPress, PHP, database.
- `emcp-tools-detect-elementor-version` → Elementor ed Elementor Pro.
- `emcp-tools-list-plugins` → plugin con aggiornamenti in sospeso, plugin
  disattivati da rimuovere, plugin abbandonati.

Termine di paragone con gli altri siti gestiti (stessi connettori, stessa
data): WordPress 7.1, PHP 8.2–8.4, Elementor 4.2.x + Pro 4.2.x. Se Alberto
Running e' su versioni sensibilmente piu' vecchie, e' li' che nasce il
malfunzionamento del connettore.

Segnale gia' noto: le email `[Alberto Running] Alcuni plugin sono stati
aggiornati automaticamente` arrivano con cadenza quasi giornaliera. Gli
aggiornamenti automatici sono attivi, ma nessuno li sta leggendo — sono tutte
non lette nella casella. Vale la pena decidere se tenerli e ridurre il rumore,
o disattivarli e passare a un controllo periodico.

## B. Sicurezza e prestazioni

- `emcp-tools-scan-security` → punteggio, integrita' dei file core, hardening,
  software obsoleto.
- `emcp-tools-analyze-performance` → opzioni autoload, arretrati di cron,
  cache oggetti, peso della home.

Il secondo e' rilevante anche per il flusso descritto in questo pacchetto: se
il cron di WordPress e' in arretrato, il promemoria del giorno 6 non parte in
orario.

## C. Il flusso di iscrizione (oggetto di questo intervento)

- Trovare la pagina con il modulo (`emcp-tools-list-pages`,
  `emcp-tools-search-content` con query "prova gratuita").
- Leggere le impostazioni attuali del modulo: quali campi, dove vanno le
  email, se c'e' gia' un redirect.
- Applicare `configurazione-elementor-form.md`.
- Creare `/grazie-prova-gratuita/` con `thankyou-page.html`, in `noindex`.
- Provare un invio reale e controllare che arrivino entrambe le email.

## D. Prezzi e listino

Nodo aperto dal 03/07/2026, mai chiuso: i prezzi del listino PDF e quelli del
sito non coincidono, e Alberto ha chiesto un listino completo con i prezzi
nuovi. Finche' resta cosi', qualunque testo che cita un importo puo' essere
sbagliato.

- Leggere i prezzi pubblicati oggi sul sito.
- Confrontarli con il listino di giugno (Base 50/140/260/490, Top
  65/165/335/655).
- Far confermare ad Alberto quale versione vale, poi allineare sito, listino
  PDF ed email in un passaggio solo.

Resta anche la sua domanda diretta, ancora senza risposta: *"come mi comporto
con gli abbonamenti trimestrale, semestrale ed annuale?"* — il flusso in
`flusso-prova-gratuita.md` la risolve (bonifico unico anticipato per l'intero
periodo, nessun rinnovo automatico, promemoria prima della scadenza).

## E. SEO e contenuti

- `emcp-tools-find-broken-links` → link rotti.
- Verificare title e meta description delle pagine principali.
- Dati strutturati `LocalBusiness` coerenti con la scheda Google Business
  ("Alberto Running Calenzano - Personal Trainer", gia' attiva anche su Bing).
- Il competitor segnalato a maggio 2026 che punta alla stessa chiave: ricontrollare
  come si e' posizionato nel frattempo.
- I contenuti del blog (resistenza lattacida, fibre muscolari, salite balzate)
  sono buoni per il posizionamento: verificare che linkino alla pagina della
  prova gratuita, che oggi e' il punto di conversione.

## F. Conversione

- Il pulsante della prova gratuita e' visibile senza scorrere, su mobile?
- La promessa "7 giorni gratis, senza carta di credito" e' ripetuta vicino al
  modulo, non solo nella hero?
- Numero di campi del modulo: ogni campo in piu' costa iscrizioni. Otto e' il
  massimo ragionevole, e tre soli obbligatori.
