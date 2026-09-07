# Flusso prova gratuita + pagamento

## Il vincolo di partenza

Il pagamento e' per **bonifico bancario**. Non e' una carta, non e' un mandato
SEPA: nessun addebito puo' partire da solo. Ne discendono tre conseguenze che
governano tutto il resto:

1. **Non esiste il rinnovo automatico.** L'abbonamento va a scadenza e basta.
   Va detto in chiaro all'utente: e' un vantaggio commerciale (nessuna
   sorpresa) e toglie ogni problema sul fronte consumatori.
2. **La riconciliazione e' manuale.** Alberto deve capire, guardando l'estratto
   conto, chi ha pagato e per cosa. Serve una **causale obbligatoria e sempre
   uguale**.
3. **Il pagamento arriva dopo la prova.** Chiederlo prima svuoterebbe di senso
   la promessa "7 giorni gratis senza carta di credito".

## Timeline

```
Giorno 0    Invio modulo
            → redirect a /grazie-prova-gratuita/
            → Email 1 all'utente (conferma, NESSUN pagamento richiesto)
            → Email 0 ad Alberto (notifica interna)

Giorno 0-1  Alberto contatta l'utente e consegna la prima tabella
            (questo e' l'impegno dichiarato nell'Email 1: va rispettato)

Giorno 6    Email 2 all'utente: la prova finisce domani.
            Importo del piano scelto + IBAN + causale.
            "Se non vuoi continuare non devi fare nulla."

Giorno 7    Fine prova gratuita.

Alla ricezione del bonifico
            Email 3: abbonamento attivo, data di inizio e di scadenza.

5 giorni prima della scadenza
            Promemoria di rinnovo (stesso schema dell'Email 2).
```

## Stati dell'iscritto

| Stato | Quando | Cosa vede l'utente |
|---|---|---|
| `in prova` | Giorno 0-7 | Nessuna richiesta di pagamento |
| `in attesa di pagamento` | Dal giorno 6 | Importo, IBAN, causale |
| `attivo` | Bonifico ricevuto | Conferma con data di scadenza |
| `scaduto` | Fine periodo pagato | Promemoria, poi stop |
| `non proseguito` | Nessun bonifico dopo la prova | Nessuna azione, nessun sollecito insistente |

## La causale del bonifico

Formato unico, da ripetere identico in ogni comunicazione:

```
Nome Cognome - Piano [Base|Top] - [1|3|6|12] mesi
```

Esempio: `Mario Rossi - Piano Base - 3 mesi`

Senza questo, con dieci iscritti al mese la riconciliazione diventa
ingestibile. E' il singolo dettaglio operativo che conta di piu'.

## Come far partire il promemoria del giorno 6

Tre strade, in ordine di sforzo:

**A. Manuale (attiva da subito, zero configurazione).**
Alberto tiene un promemoria in calendario a 6 giorni dall'iscrizione e invia
il testo dell'Email 2. Funziona finche' i volumi sono bassi.

**B. Automazione con FluentCRM (consigliata).**
Plugin gratuito, si integra nativamente con i moduli Elementor: trigger
"Elementor form submitted" → attesa 6 giorni → invio Email 2. Gestisce anche
i promemoria di scadenza e tiene la lista contatti in ordine. E' la soluzione
giusta se le iscrizioni crescono.

**C. Snippet PHP** (`snippet-promemoria-giorno6.php`).
Nessun plugin in piu'. Da valutare solo se non si vuole installare FluentCRM;
dipende da WP-Cron, che su un sito con poco traffico non parte in orario se
non e' agganciato a un cron reale di sistema.

## Aspetti da far verificare ad Alberto (non implementati qui)

- **Diritto di recesso.** Vendita a distanza a un consumatore: 14 giorni di
  recesso. Con la prova gratuita di 7 giorni il rischio pratico e' basso, ma
  le condizioni dovrebbero dirlo esplicitamente. Da far leggere a chi gli
  segue la parte fiscale/legale — non e' materia da definire in autonomia.
- **Regime fiscale e ricevute.** Chi emette la ricevuta, con che tempi, e se
  va allegata all'Email 3.
- **Prezzi.** Listino PDF e sito non coincidono (mail del 03/07/2026). Vanno
  allineati prima di pubblicare qualunque testo che citi un importo.
