#!/bin/bash
# Work in progress that the handoff has to notice: started, untracked, unwired.
cat > src/images/webp.js <<'JS'
// WebP encode wrapper. Quality default chosen to match the JPEG pipeline.
const DEFAULT_QUALITY = 82;

function encodeOptions(quality = DEFAULT_QUALITY) {
	return { format: 'webp', quality };
}

module.exports = { encodeOptions, DEFAULT_QUALITY };
JS
