const DEFAULT_PORT = 3000;

function start(port = DEFAULT_PORT) {
	return `listening on ${port}`;
}

module.exports = { start, DEFAULT_PORT };
