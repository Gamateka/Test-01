# Punto 5 — Prezzi: cosa dice il listino, cosa manca ancora

## Stato

Fatto a meta', e la meta' fatta e' quella che si poteva fare senza sito.

- **Lato listino: ricostruito.** Il PDF e' stato recuperato dall'allegato della
  mail "listino" del 03/07/2026 ed estratto per intero (sotto, verbatim).
- **Lato sito: non verificabile.** Il connettore e' disconnesso e l'HTTP verso
  il dominio e' bloccato, quindi i prezzi pubblicati non sono leggibili. Il
  confronto vero e proprio resta da fare.

## Il listino PDF, per intero

Fonte: allegato `ALBERTO BISCARDI Listino .pdf` (138 KB, 2 pagine) alla mail
"listino" del 03/07/2026 da `biscardialberto@gmail.com`.

Intestazione: **ALBERTO BISCARDI — Personal Trainer & Coach**, Via Nuova 10/c,
Calenzano (FI), P.I. 0730090484. Titolo: **LISTINO ATTIVITA' 2026**.

### Tariffe abbonamenti

| Durata | Piano BASE | Piano TOP |
|---|---|---|
| 1 Mese | € 50,00 | € 65,00 |
| 3 Mesi | € 140,00 | € 165,00 |
| 6 Mesi | € 260,00 | € 335,00 |
| 12 Mesi | € 490,00 | € 655,00 |

### Cosa e' incluso

**Piano BASE** (consulenza settimanale): programma di allenamento con tabella
personalizzata; analisi settimanale dei risultati; 1 telefonata di confronto a
settimana.

**Piano TOP** (consulenza giornaliera): programma di allenamento con tabella
personalizzata; **test iniziale sul ritmo corsa**; analisi settimanale dei
risultati; 1 telefonata a settimana + supporto e messaggi giornalieri;
**garanzia di recupero giorni inclusa**.

### Servizi individuali e sessioni singole

Tariffe escluse eventuali trasferte.

| Servizio | Durata | Prezzo |
|---|---|---|
| Tecnica di Corsa | 1h | € 40,00 |
| Posturale e Biomeccanica | 1h 30' | € 80,00 |

### Modalita' di pagamento (pagina 2 del PDF)

- Istituto: BANCA WIDIBA (GRUPPO MPS)
- IBAN: IT97V0344214239PREP90084833
- Intestatario: Alberto Biscardi

Coincide con quanto gia' usato nel pacchetto: su questo non ci sono dubbi.

## Il confronto che si e' potuto fare

Ci sono **tre** fonti di prezzo in gioco, non due:

| # | Fonte | Data | Tariffe abbonamenti |
|---|---|---|---|
| A | Mail "Possibile struttura piano web tariffe" | 03/06/2026 | 50 / 140 / 260 / 490 — 65 / 165 / 335 / 655 |
| B | PDF "ALBERTO BISCARDI Listino" | 03/07/2026 | 50 / 140 / 260 / 490 — 65 / 165 / 335 / 655 |
| C | Quello che e' **pubblicato sul sito** | oggi | **non leggibile** |

**A e B coincidono, valore per valore, su tutte e otto le tariffe.** Non e' una
coincidenza: la struttura web proposta a giugno era ricavata dal listino.

Quindi il disallineamento segnalato da Alberto non e' tra listino e struttura
web: e' tra quelle due, che concordano, e **C**, cioe' quello che sul sito c'e'
davvero. Che e' esattamente il termine che manca.

## Il dettaglio che cambia la direzione del lavoro

Il testo della mail del 03/07/2026, integrale:

> Ciao,
> Ti allego quello che e' il mio listino attuale.
>
> C'e' da uniformare I prezzi del listino con quelli che hai scritto sul sito.
> E poi come mi comporto con gli abbonamenti trimestrale, semestrale ed annuale?
> Riesci tu a farmi un listino completo seguendo I nuovi prezzi del sito?

Due cose, entrambe rilevanti:

1. **La direzione dell'allineamento e' sito -> listino**, non listino -> sito.
   Alberto chiede un listino nuovo che segua i prezzi del sito. Il `README.md`
   del pacchetto lo riporta invece come "va verificato quale dei due e' quello
   buono": la mail e' piu' netta di cosi'.
2. **C'e' una domanda aperta rimasta senza risposta**: come comportarsi con
   trimestrale, semestrale e annuale. Va chiusa con Alberto, non decisa qui.

Ne discende la conseguenza pratica gia' segnalata in
`stato-esecuzione-e-runbook.md`: gli otto importi scritti dentro
`thankyou-page.html` sono quelli di **B**, e se il sito porta numeri diversi
sono quelli sbagliati da pubblicare.

## Incongruenze interne al materiale, da chiarire con Alberto

Sono emerse leggendo il PDF accanto alla mail di giugno. Nessuna e' decidibile
in autonomia.

### 1. La garanzia di recupero si contraddice

Il PDF dice due cose diverse nella stessa pagina:

- nell'elenco dei servizi, "garanzia di recupero giorni inclusa" compare **solo**
  sotto il Piano TOP;
- nella nota integrativa: "Per tutti i piani (escluso il piano Base) e' garantito
  il recupero...".

E la mail del 03/06/2026 ne dice una terza:

> Valida per tutti i piani in abbonamento (esclusa la sola "tabella base").

"Esclusa la sola tabella base" e "escluso il piano Base" non sono la stessa
esclusione: la prima esclude il prodotto singolo, e quindi il Piano Base
l'avrebbe; la seconda esclude il Piano Base. Da decidere quale vale prima di
scriverlo da qualche parte.

### 2. Il PDF cita una soglia che la mail non ha

PDF: recupero "a partire da un minimo di 7 giorni consecutivi di stop".
Mail: "per periodi di stop pari o superiori a 7 giorni". Qui sono compatibili,
ma vale la pena fissare una formulazione unica.

### 3. Due servizi che nel materiale web non esistono

Tecnica di Corsa (€ 40,00) e Posturale e Biomeccanica (€ 80,00) sono nel listino
ma non compaiono nella struttura web di giugno ne' nel pacchetto. Da capire se
vanno pubblicati o se restano fuori sito di proposito.

### 4. Il Piano TOP include un test iniziale che la mail non menziona

Il "test iniziale sul ritmo corsa" c'e' solo nel PDF. Se e' un elemento di
vendita, sul sito manca.

## Cosa resta da fare, a connettore riattivato

1. `emcp-tools-search-content` cercando `euro`, `€`, e i singoli importi
   (`50`, `140`, `260`, `490`, `65`, `165`, `335`, `655`) per trovare **tutti** i
   punti del sito che citano un prezzo — pagine, popup, template Elementor.
   Probabilmente non e' un punto solo, ed e' questo che rende il disallineamento
   difficile da chiudere a mano.
2. Compilare la colonna C della tabella qui sopra con i valori reali.
3. Portare la differenza ad Alberto insieme alle quattro incongruenze,
   e farsi dire quali sono i numeri buoni.
4. Solo allora: allineare in **un punto solo** e aggiornare di conseguenza
   `thankyou-page.html`, il listino PDF e i testi delle email.
