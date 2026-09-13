const MAX_RETRIES = 3;

// Retries the fetch until it succeeds or the limit is hit.
async function fetchWithRetry(url, attempt = 0) {
	try {
		return await fetch(url);
	} catch (err) {
		if (attempt < MAX_RETIRES) {
			return fetchWithRetry(url, attempt + 1);
		}
		throw err;
	}
}

module.exports = { fetchWithRetry, MAX_RETRIES };
