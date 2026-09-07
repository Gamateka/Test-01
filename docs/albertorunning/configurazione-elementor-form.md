# Configurazione del modulo Elementor

## 1. Campi del modulo

Il modulo deve raccogliere abbastanza da poter scrivere l'email del giorno 6
senza dover ricostruire a mano che cosa aveva chiesto la persona.

| ID campo | Etichetta | Tipo | Obbligatorio |
|---|---|---|---|
| `nome` | Nome e cognome | Testo | si |
| `email` | Email | Email | si |
| `telefono` | Telefono | Tel | si |
| `piano` | Quale piano ti interessa | Select: `Base — consulenza settimanale` / `Top — consulenza giornaliera` / `Non lo so ancora` | si |
| `durata` | Per quanto tempo | Select: `1 mese` / `3 mesi` / `6 mesi` / `12 mesi` / `Decido dopo la prova` | no |
| `obiettivo` | Il tuo obiettivo | Select o testo (es. 10 km, mezza, maratona, rimettermi in forma) | no |
| `messaggio` | Raccontami qualcosa di te | Textarea | no |
| `privacy` | Accettazione privacy policy | Acceptance | si |

Due note sulle scelte:

- **`piano` e `durata` con l'opzione "non lo so / decido dopo"**: obbligare a
  scegliere un piano prima ancora di aver parlato con Alberto aggiunge attrito
  proprio dove serve meno. Chi non sa, lo dice, e si decide in telefonata.
- **`privacy` come campo Acceptance**: obbligatorio, con link alla privacy
  policy. Senza, la raccolta dei dati non e' in regola.

## 2. Azioni dopo l'invio

Impostare, in quest'ordine: **Email**, **Email 2**, **Redirect**.

### Email (notifica interna ad Alberto)
- **A:** `info@albertorunning.it`
- **Oggetto:** `[Prova gratuita] Nuova richiesta: [field id="nome"] - [field id="piano"]`
- **Corpo:** vedi `email/00-notifica-admin.txt`
- **Reply-To:** `[field id="email"]` — cosi' Alberto risponde direttamente
  dalla notifica senza copiare l'indirizzo.

### Email 2 (autorisponditore all'utente)
- **A:** `[field id="email"]`
- **Oggetto:** `La tua prova gratuita di 7 giorni e' attiva`
- **Da:** `info@albertorunning.it`
- **Nome mittente:** `Alberto Biscardi - Alberto Running`
- **Reply-To:** `info@albertorunning.it`
- **Corpo:** vedi `email/01-conferma-iscrizione.html`
  (in Elementor impostare il tipo su HTML)

### Redirect
- **URL:** `/grazie-prova-gratuita/`

## 3. La pagina di ringraziamento

- Slug: `/grazie-prova-gratuita/`
- Contenuto: `thankyou-page.html`
- **Impostare `noindex`** (Yoast / Rank Math → Avanzate → Nessun indice).
  E' una pagina che ha senso solo dopo l'invio del modulo: indicizzata sporca
  i dati di conversione e mostra l'IBAN a chi arriva da una ricerca.
- Escluderla dalla sitemap.
- Se e' attivo un tracciamento conversioni (GA4 / Google Ads), questa pagina e'
  il punto giusto in cui far scattare l'evento.

## 4. Deliverability: il punto piu' fragile di tutto il flusso

Il flusso si regge su email che devono arrivare davvero. Se l'invio parte dal
`wp_mail()` di default del server, una parte finisce in spam e le iscrizioni
si perdono in silenzio.

Da verificare, in ordine:

1. **SPF, DKIM e DMARC** sul dominio `albertorunning.it`.
2. **Plugin SMTP** (FluentSMTP, gratuito) collegato a un servizio di invio
   reale — Brevo, Mailgun, o la casella stessa via SMTP autenticato.
3. **Invio di prova** a Gmail, Outlook e a un dominio proprietario, con
   controllo della cartella spam su ognuno.

Finche' questo punto non e' sistemato, il resto vale poco.
