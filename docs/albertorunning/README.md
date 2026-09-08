# Alberto Running — Pagamenti, Prova Gratuita e Thank You Page

Pacchetto di intervento per **albertorunning.it** (WordPress + Elementor).

## Perche' questo pacchetto esiste come file e non come modifica diretta al sito

La sessione da cui e' stato prodotto **non ha accesso al sito**:

- tra i connettori MCP installati non c'e' quello di Alberto Running
  (sono presenti solo: Fabio Cioni, MyNutritional, Sempoint, SmartLands GIS);
- l'egress di rete dell'ambiente e' bloccato verso tutti i domini esterni,
  quindi il sito non e' raggiungibile nemmeno in sola lettura via HTTP.

Tutto il contenuto qui dentro e' **pronto per essere applicato**: appena il
connettore e' attivo, i testi, l'HTML e le impostazioni si riportano sul sito
cosi' come sono.

## Il problema che questo pacchetto risolve

Il sito promette **7 giorni di prova gratuita senza carta di credito**, ma il
pagamento avviene per **bonifico bancario** (nessun addebito automatico
possibile). Chi compila il modulo oggi non riceve nessuna indicazione su come
e *quando* si paga.

Mettere le coordinate bancarie subito dopo l'invio del modulo, senza contesto,
contraddirebbe la promessa della prova gratuita e farebbe perdere iscrizioni.
La soluzione adottata separa i due momenti:

1. **Iscrizione** → nessun pagamento richiesto, si spiega cosa succede adesso;
   le coordinate ci sono ma in un blocco secondario "ti serviranno solo dopo".
2. **Giorno 6** → promemoria di fine prova con importo, coordinate e causale.
3. **A bonifico ricevuto** → conferma di attivazione.

## Contenuto

| File | Cosa e' |
|---|---|
| `flusso-prova-gratuita.md` | Specifica del flusso: timeline, stati, chi fa cosa |
| `thankyou-page.html` | Pagina di ringraziamento completa, pronta da incollare |
| `email/01-conferma-iscrizione.html` | Email automatica all'utente subito dopo l'invio |
| `email/01-conferma-iscrizione.txt` | Versione testo della stessa email |
| `email/02-fine-prova-pagamento.html` | Email di fine prova con istruzioni di pagamento |
| `email/02-fine-prova-pagamento.txt` | Versione testo della stessa email |
| `email/03-conferma-pagamento.txt` | Conferma di attivazione a bonifico ricevuto |
| `email/00-notifica-admin.txt` | Notifica interna ad Alberto a ogni iscrizione |
| `configurazione-elementor-form.md` | Impostazioni esatte del modulo Elementor |
| `snippet-promemoria-giorno6.php` | Snippet opzionale per automatizzare il promemoria |
| `checklist-verifica-sito.md` | Controllo generale da eseguire a connettore attivo |

## Dati di pagamento usati

Fonte: email "iban" del 01/09/2026 da info@albertorunning.it.

- Istituto: **BANCA WIDIBA (GRUPPO MPS)**
- IBAN: **IT97V0344214239PREP90084833**
- Intestatario: **Alberto Biscardi**

## Prezzi: da confermare prima della pubblicazione

I prezzi usati nei testi vengono dalla mail "Possibile struttura piano web
tariffe" del 03/06/2026. Il 03/07/2026 Alberto ha scritto che *"c'e' da
uniformare i prezzi del listino con quelli che hai scritto sul sito"*: quindi
listino PDF e sito **non coincidono**. Prima di pubblicare va verificato quale
dei due e' quello buono, e sistemato di conseguenza in un punto solo.

| Piano | 1 mese | 3 mesi | 6 mesi | 12 mesi |
|---|---|---|---|---|
| Base (consulenza settimanale) | 50 € | 140 € | 260 € | 490 € |
| Top (consulenza giornaliera) | 65 € | 165 € | 335 € | 655 € |
