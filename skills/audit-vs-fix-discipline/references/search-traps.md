# Search traps

Two ways a search returns nothing and reads as an answer. Both cost real findings. Three directives, then the worked examples behind them.

- Check every caller before describing or changing a function. Grep for each call site and read the hits.
- Search for the bare identifier, never a phrase containing it.
- A search that finds nothing proves nothing until the pattern is tested against a hit you know exists.

## A phrase pattern assumes word adjacency

Search for the bare identifier, never a phrase containing it. A multi-word pattern assumes those words sit adjacent on one line, and quotes, punctuation, line breaks and markdown formatting all break that.

`debugging skill` returned nothing. The tree contained `Invoke the 'debugging' skill`, where a quote sits between the two words. The empty result read as "no references remain", and a hook was left pointing at a file that had just been deleted.

Grep the name on its own, accept the wider result set, and read the hits.

## An untested pattern's silence carries no information

Before reporting that there are no callers, run the pattern against one hit you know exists. If it cannot find that, the zero-result run proves nothing about the rest of the tree.

This costs one command, and it separates "there are none" from "I did not find any". Those are different claims, and only the second one is earned by a search that was never validated.

## A same-line `grep -v` is a blind spot, not a narrowing

`grep -rn matchesGlob rules/ skills/ | grep -v rules-creator` returned nothing and read as success. The filter had removed exactly the evidence being sought, because the match and the excluded term sat on the same line.

Filter on a separate field, or read the unfiltered output.

## Know which grep you have

`grep` on a given machine may be ugrep, and `awk` may be BWK awk rather than GNU awk. A pattern starting with `--` then fails as an option rather than matching nothing, and there is no `IGNORECASE`. Run `grep --version` once before trusting an empty result from an unfamiliar flag.
