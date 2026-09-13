const test = require('node:test');
const assert = require('node:assert');
const { targetWidth, scale } = require('../src/images/optimise.js');

test('caps width at max', () => {
	assert.strictEqual(targetWidth(4000, 1600), 1600);
});

test('leaves small images alone', () => {
	assert.strictEqual(targetWidth(800, 1600), 800);
});

test('scales height with width', () => {
	assert.deepStrictEqual(scale({ width: 3200, height: 1600 }, 1600), { width: 1600, height: 800 });
});

test('rounds height up on odd ratios', () => {
	assert.deepStrictEqual(scale({ width: 3000, height: 1001 }, 1500), { width: 1500, height: 501 });
});
