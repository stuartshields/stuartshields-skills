# Handoff

## Session 2026-09-10

Working on the image optimiser. `src/optimise.js` handles the resize maths.
There are 3 failing tests in `tests/optimise.test.js`, all around height
rounding. WebP output is not started.

## Key files

- `src/optimise.js`: resize maths
- `tests/optimise.test.js`: 4 tests, 3 failing

## Next steps

- Fix the 3 failing height-rounding tests
- Start WebP support
