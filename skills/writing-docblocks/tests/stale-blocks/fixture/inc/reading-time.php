<?php
/**
 * Reading time helpers.
 *
 * @package Site\Reading
 */

namespace Site\Reading;

/**
 * This function is used to count the words in a block of post content.
 *
 * @since 1.2.0
 *
 * @param string $content Raw post content.
 * @return int Word count, zero for empty content.
 */
function count_words( string $content ): int {
	$text = wp_strip_all_tags( strip_shortcodes( $content ) );
	return str_word_count( $text );
}

/**
 * Estimates the reading time for a post.
 *
 * @since 1.2.0
 *
 * @param WP_Post $post             The post object.
 * @param int     $words_per_minute Reading speed. Default 200.
 * @param bool    $round_up         Whether to round up. Default true.
 * @return string Reading time label.
 */
function get_reading_time( int $post_id, int $words_per_minute = 200 ): int {
	$post = get_post( $post_id );
	if ( ! $post ) {
		return 0;
	}
	$words   = count_words( $post->post_content );
	$minutes = (int) ceil( $words / max( 1, $words_per_minute ) );
	return max( 1, $minutes );
}

/**
 * Formats a reading time for display.
 *
 * @since 1.2.0
 *
 * @param int $minutes Whole minutes.
 * @return string Translated label, for example "3 min read".
 */
function format_reading_time( int $minutes ): string {
	/* translators: %d: reading time in minutes. */
	return sprintf( _n( '%d min read', '%d min read', $minutes, 'site' ), $minutes );
}
