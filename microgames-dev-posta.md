# Posta di microgames.dev — stato al 19 settembre 2026

Promemoria operativo della sessione. Il documento tecnico vero sta nel
deposito del progetto: `docs/posta.md` dentro la PR
[Gamateka/microgames#3](https://github.com/Gamateka/microgames/pull/3).

## Da dove si riparte

microgames.dev non aveva nessun record di posta. Il sito lo diceva in tre
punti del codice e pubblicava `info@sempoint.it` come recapito; le richieste
dei moduli finivano in Postgres con un avviso su Telegram, e la password
temporanea del pannello era stata mandata a mano da Gmail.

## Fatto

Nella zona Cloudflare `microgames.dev`:

| Record | Valore |
|---|---|
| MX (×3) | `route1/2/3.mx.cloudflare.net` — Email Routing acceso |
| TXT radice | `v=spf1 include:_spf.mx.cloudflare.net ~all` |
| TXT `cf2024-1._domainkey` | chiave DKIM di Cloudflare |
| TXT `_dmarc` | `v=DMARC1; p=none; fo=1; rua=mailto:info@microgames.dev` |

Destinazione d'inoltro creata: `cionifabio6@gmail.com` (**da verificare**).
I tre record A del sito non sono stati toccati.

Nel codice (PR #3, bozza): `mg/posta.py` per l'invio SMTP, l'avviso delle
richieste anche per email, `RECAPITO = info@microgames.dev` nelle pagine e
nella privacy, `docs/posta.md`, prove nuove.

## Serve da Fabio

1. Aprire il link nella mail Cloudflare «[Action required] Verify your Email
   Routing address» arrivata su cionifabio6@gmail.com il 19/09 alle 01:56.
2. Dopo la verifica: creo la regola `info@microgames.dev → Gmail` e si può
   fondere la PR.
3. Su Brevo (stesso account di fabiocioni.it): aggiungere il dominio
   microgames.dev e passare i record che mostra, più la chiave SMTP. Poi il
   pannello manda gli avvisi e Gmail può «inviare come» info@microgames.dev.

## Scelta aperta (19/09, da decidere alla ripresa)

Quello che c'è adesso è un **alias**: `info@microgames.dev` non ha una casella
sua, i messaggi passano da Cloudflare e cadono in Gmail. Si riceve, ma la
risposta parte da cionifabio6@gmail.com. Le strade per avere l'indirizzo che
risponde anche in uscita:

| | Dove sta la casella | Ricevi | Rispondi come info@ | Costo | Chi fa cosa |
|---|---|---|---|---|---|
| **A. Alias Cloudflare** (in corso) | nessuna, gira su Gmail | sì | no | 0 € | manca solo il clic di verifica |
| **B. Casella su cPanel** di fabiocioni.it | server 89.40.174.29 | sì | sì | incluso, se il piano regge un altro dominio | Fabio crea la casella, io sposto gli MX su mail.fabiocioni.it e rifaccio SPF/DKIM |
| **C. Provider di posta** (Proton, Zoho, Google) | dal provider | sì | sì | ~4-7 €/mese | Fabio attiva il dominio, io metto i record |

Le tre si escludono. Primo controllo da fare: in cPanel, se si può aggiungere
`microgames.dev` come dominio. Se sì, la B non costa niente di nuovo.

Non si mette un server di posta sulla macchina di microgames (178.105.21.154):
servirebbero Postfix, Dovecot, TLS, PTR da Hetzner, la porta 25 sbloccata e la
manutenzione — per un indirizzo solo non vale.

## Scelte prese, e perché

- **Email Routing invece di una casella vera**: gratis, nessuna casella in
  più da leggere, e la posta arriva dove Fabio guarda già. Non manda: per
  quello serve il relay.
- **Solo `info@`**, niente catch-all: un catch-all inoltra anche ogni
  tentativo a caso degli spammer.
- **Brevo invece di un altro relay**: l'account esiste già ed è autenticato
  su fabiocioni.it.
- **`p=none` su DMARC**: si ascolta prima di stringere a `quarantine`.
- **Niente password per email**: `reimposta-password.py` resta com'è.
