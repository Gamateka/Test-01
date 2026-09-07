<?php
/**
 * Alberto Running - Promemoria automatico di fine prova gratuita.
 *
 * Alla ricezione di un invio del modulo "Prova Gratuita" programma, a 6 giorni
 * di distanza, l'invio dell'email con le istruzioni di pagamento.
 *
 * OPZIONALE: serve solo se non si usa FluentCRM (soluzione consigliata).
 *
 * Da installare come snippet (Code Snippets / WPCode) oppure nel functions.php
 * del child theme. NON incollare in un file del tema padre.
 *
 * ATTENZIONE - dipende da WP-Cron: su un sito con poco traffico gli eventi
 * programmati partono solo quando qualcuno visita il sito, quindi il
 * promemoria puo' arrivare in ritardo. Per renderlo affidabile va disattivato
 * il cron via web (define('DISABLE_WP_CRON', true) in wp-config.php) e
 * agganciato wp-cron.php a un cron reale del server, ogni 15 minuti.
 */

defined( 'ABSPATH' ) || exit;

/**
 * Nome del modulo Elementor su cui agire.
 * Deve coincidere con "Nome modulo" nelle impostazioni del widget.
 */
if ( ! defined( 'AR_NOME_MODULO' ) ) {
	define( 'AR_NOME_MODULO', 'Prova Gratuita' );
}

/**
 * Intercetta l'invio del modulo e programma il promemoria.
 */
add_action(
	'elementor_pro/forms/new_record',
	function ( $record, $handler ) {
		if ( AR_NOME_MODULO !== $record->get_form_settings( 'form_name' ) ) {
			return;
		}

		$dati = array();
		foreach ( $record->get( 'fields' ) as $id => $campo ) {
			$dati[ $id ] = $campo['value'];
		}

		if ( empty( $dati['email'] ) || ! is_email( $dati['email'] ) ) {
			return;
		}

		$payload = array(
			'email'  => sanitize_email( $dati['email'] ),
			'nome'   => sanitize_text_field( $dati['nome'] ?? '' ),
			'piano'  => sanitize_text_field( $dati['piano'] ?? '' ),
			'durata' => sanitize_text_field( $dati['durata'] ?? '' ),
		);

		wp_schedule_single_event(
			time() + ( 6 * DAY_IN_SECONDS ),
			'ar_promemoria_fine_prova',
			array( $payload )
		);
	},
	10,
	2
);

/**
 * Invia il promemoria del giorno 6.
 */
add_action(
	'ar_promemoria_fine_prova',
	function ( $dati ) {
		if ( empty( $dati['email'] ) || ! is_email( $dati['email'] ) ) {
			return;
		}

		$nome   = $dati['nome'] ? $dati['nome'] : 'ciao';
		$piano  = $dati['piano'] ? $dati['piano'] : 'il piano che sceglierai';
		$durata = $dati['durata'] ? $dati['durata'] : 'la durata che sceglierai';

		$oggetto = 'La tua prova gratuita finisce domani - come continuare';

		$corpo  = '<p>Ciao <strong>' . esc_html( $nome ) . '</strong>,</p>';
		$corpo .= '<p>siamo al sesto giorno: domani la tua prova gratuita si conclude. '
			. 'Se ti sei trovato bene e vuoi continuare, qui sotto trovi tutto quello che serve. '
			. 'Se invece preferisci fermarti, <strong>non devi fare nulla</strong> e non ti verra&#39; '
			. 'chiesto nessun pagamento.</p>';
		$corpo .= '<p>Il tuo piano: <strong>' . esc_html( $piano ) . '</strong> &mdash; '
			. '<strong>' . esc_html( $durata ) . '</strong></p>';
		$corpo .= '<p><strong>Coordinate per il bonifico</strong><br>'
			. 'Istituto: Banca Widiba (Gruppo MPS)<br>'
			. 'IBAN: <strong>IT97V0344214239PREP90084833</strong><br>'
			. 'Intestatario: Alberto Biscardi</p>';
		$corpo .= '<p><strong>Causale da indicare:</strong><br>'
			. esc_html( $nome ) . ' - Piano ' . esc_html( $piano ) . ' - ' . esc_html( $durata )
			. '<br><small>Serve per abbinare il bonifico alla tua iscrizione.</small></p>';
		$corpo .= '<p>Appena vedo l&#39;accredito ti mando la conferma con la data di inizio e '
			. 'di scadenza dell&#39;abbonamento.</p>';
		$corpo .= '<p><strong>Nessun rinnovo automatico:</strong> e&#39; un bonifico singolo, '
			. 'l&#39;abbonamento vale per il periodo scelto e si ferma alla scadenza.</p>';
		$corpo .= '<p>A presto,<br><strong>Alberto Biscardi</strong><br>'
			. 'Istruttore FIDAL &middot; Alberto Running</p>';

		$intestazioni = array(
			'Content-Type: text/html; charset=UTF-8',
			'From: Alberto Running <info@albertorunning.it>',
			'Reply-To: info@albertorunning.it',
			'Bcc: info@albertorunning.it',
		);

		wp_mail( $dati['email'], $oggetto, $corpo, $intestazioni );
	}
);
