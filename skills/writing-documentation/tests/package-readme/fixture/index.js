const DEFAULT_MAX_LENGTH = 80;

/**
 * Turns a title into a URL slug.
 *
 * Latin diacritics are stripped by NFD decomposition. Scripts with no Latin
 * decomposition, such as CJK, produce an empty string; callers wanting those
 * need a transliteration library instead.
 *
 * @param {string} title
 * @param {{ separator?: string, maxLength?: number }} [options]
 * @return {string}
 */
function slugify(title, { separator = '-', maxLength = DEFAULT_MAX_LENGTH } = {}) {
	const ascii = title.normalize('NFD').replace(/[̀-ͯ]/g, '');
	const joined = ascii
		.toLowerCase()
		.replace(/[^a-z0-9]+/g, separator)
		.replace(new RegExp(`^\\${separator}+|\\${separator}+$`, 'g'), '');
	if (joined.length <= maxLength) {
		return joined;
	}
	const cut = joined.slice(0, maxLength);
	const boundary = cut.lastIndexOf(separator);
	return boundary > 0 ? cut.slice(0, boundary) : cut;
}

module.exports = { slugify, DEFAULT_MAX_LENGTH };
