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
