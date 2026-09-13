function targetWidth(width, max) {
	return width > max ? max : width;
}

function scale(dimensions, maxWidth) {
	const w = targetWidth(dimensions.width, maxWidth);
	const ratio = w / dimensions.width;
	return { width: w, height: Math.round(dimensions.height * ratio) };
}

module.exports = { targetWidth, scale };
