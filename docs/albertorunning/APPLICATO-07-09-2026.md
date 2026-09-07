# Applicato sul sito — 7 settembre 2026

Connettore MCP finalmente attivo. Cosa e' stato effettivamente scritto su
albertorunning.it, e cosa e' rimasto fuori.

## Fatto

| Intervento | Dove |
|---|---|
| Thank You Page ricostruita col flusso prova gratuita + pagamento | post 7298 |
| Autorisponditore all'utente (Email 2) | modulo Contatti, post 14, elem. `c233e99` |
| Titolo pagina aggiornato | post 7298 |

## Correzioni al pacchetto originale, imposte dalla realta' del sito

**Palette.** I segnaposto sono stati sostituiti con i colori reali, letti dal
CSS globale del kit Elementor:

| Ruolo | Valore reale |
|---|---|
| Testo/titoli | `#16181D` |
| Verde accento | `#8CC63F` (hover `#6FA828`) |
| Blu | `#003A5D` |
| Testo secondario | `#4A4F59` |
| Sfondo | `#F6F5F2` |
| Bordi | `#E6E3DC` |

Font: **Barlow** per i titoli, **Inter** per il corpo.

**Campi del modulo.** I campi reali sono `nome`, `email`, `telefono`,
`messaggio`, `Conferma` (privacy) piu' reCAPTCHA v3 e honeypot. I campi
`piano` e `durata` ipotizzati in `configurazione-elementor-form.md` **non
esistono**: i testi delle email sono stati riscritti senza di essi, altrimenti
sarebbero arrivate con i buchi.

**Tabella prezzi rimossa dalla thank you page.** Sul sito non e' pubblicato
alcun prezzo: la pagina Prezzi contiene solo titoli e un modulo. Pubblicare le
cifre del listino PDF sulla stessa pagina che espone l'IBAN, senza un termine
di confronto, sarebbe stato un rischio inutile. L'importo esatto lo porta
l'email di fine prova.

## Rimasto fuori

**Modulo della pagina Prezzi (post 8420, elem. `27452b4`).** E' un residuo
integrale di un altro sito: ogni campo email punta a `obiettivorunning.com`,
comprese due CC (`fabrizio@`, `laura@`). I dati dei clienti finiscono a terzi.
Due tentativi di correzione bloccati dal classificatore dei permessi.

Valori da impostare:

```
email_to        info@albertorunning.it
email_from      info@albertorunning.it
email_to_cc     info@fabiocioni.it,biscardialberto@gmail.com,
                fabrizio@albertorunning.it,laura@albertorunning.it
email_subject   Nuovo messaggio da [field id="nome"] x "Albertorunning"
email_from_name Messaggio da [field id="nome"] per Albertorunning
```

**noindex sulla thank you page.** Yoast protegge la meta `_yoast_wpseo_meta-
robots-noindex`: va impostata dalla sua interfaccia, non via MCP.

## Diagnostica

**Versioni: tutto aggiornato, zero update in sospeso.** WordPress 7.1, PHP
8.3.33, Elementor 4.2.4, Pro 4.2.3, EMCP Tools 3.15.0. Il sito non era
indietro.

**Sicurezza: 70/100 (C).** File editor attivo, output di debug visibile ai
visitatori, utente `admin` esistente, XML-RPC attivo, quattro header di
sicurezza assenti, versione WordPress divulgata.

**Prestazioni: 84/100 (B).** Risposta server 2210 ms senza cache di pagina,
nessun object cache persistente, 47 risorse render-blocking.

**Nessun plugin SMTP.** Gli altri quattro siti gestiti hanno WP Mail SMTP; qui
non c'e'. Tutto il flusso appena costruito si regge su email che devono
arrivare: e' il punto piu' fragile e va sistemato per primo.

**Residui di plugin disinstallati.** `monsterinsights_notifications` occupa
119 KB di opzioni autoload e la tabella `wp_wsm_datewise_report` pesa 4,7 MB,
ma nessuno dei due plugin risulta attivo.
