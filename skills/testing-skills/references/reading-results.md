# Reading results

The summary table ranks what to read first. The verdict comes from the replies and the edited fixtures, read one at a time.

## Traps, with the run that produced each

**A grep matches a quoted counter-example.** A pull-request reply containing "I avoided opening with 'This PR'" matches a banned-opener check. A README that says "there is no CJK support" matches a check for a named limitation, and so does one that says "full CJK support" if the pattern is loose. Open the line the count points at.

**The control arm never fails, so the skill looks redundant.** Two audit fixtures, one with a plain off-by-one and one with a one-character typo under an urgent request, drew no edit from any control run. The prohibition the skill leads with was not what the test measured. The discriminating rows were the tier headers, the placement of speculation, and the closing ask. Either the fixture needs to tempt harder, or the skill's value on that scenario is the part that did discriminate, and the report should say which.

**The fixture carries the rule under test.** A pull-request scenario run from a branch whose diff added "print the body inside a fenced block" produced fenced output in every control run. The control had read the rule in the diff. Read the fixture as the control arm will, and move the rule out of it or pick another branch.

**Two identical treatment replies from two reps.** In the php-tdd matrix of 2026-09-12, every key an arm held at 3/5 read as 2/2 in three of its ten two-rep subsamples, and a key held at 4/5 read as 2/2 in six. A matching pair supports the direction of an effect when the other arm differs from it; it does not support a count. `--stage` extends an arm whose pair disagrees and a scenario whose arms match, and a reported "5 of 5" comes from five reps.

**A treatment reply that is right for the wrong reason.** A documentation run checked the npm registry, found an unrelated package under the fixture's name, and treated the hit as confirmation that the install command was correct. Another found the same package and warned that the name was taken. Same skill, same rep count, opposite conclusions. The skill said to verify and not what a match had to satisfy. That is a finding about the skill text, not a pass.

**A tool's verdict passes and the defect is still there.** A pricing-section run assembled a band whose background colour named a preset the theme does not define, and `validate` returned clean, because the class the block emitted agrees with the attribute it was built from. The check was correct and measured the wrong property: a validator answers "is this well-formed", never "is this what was asked for". Where a check delegates to a tool, name what that tool's pass does not cover, and add the key that covers it.

**A zero the request never gave anything to measure.** An edit teaching the shape of one attribute scored zero in every run after it, which read as text that failed to bind. The request asked for a button "across the bottom of the card", which the model took as placement, so no run attempted a width and nothing could have bound. A null means the skill did not change the behaviour only if the control arm attempted that behaviour at all. Check that first, and where the request never provokes it, the scenario is measuring nothing and the answer is another scenario rather than another edit.

**A control that was not clean.** Any run spawned from inside a session carries the user's global rules. One control cited the user's own style rule by name. Results from such runs measure what the skill adds on top of those rules, which is a different claim from what the skill does on its own. `ambient_memory_files` in each run's `usage.txt` is the count, and the summary warns when it is above zero. State which claim the runs support.

**Counts from either side of a harness change.** Until 2026-09-13 the treatment prompt ended with a clause telling the model it could not ask the user, which the control never saw. Treatment replies from before that date open assumption sections the same request no longer prompts, and any skill judged on whether it closes with a question was being judged against a prompt that discouraged one. Check what the runner sent before lining up counts from different days.

## What to record

For each scenario, one line per arm: how many reps produced the target shape, and which reply to open for the exception. Then the finding about the skill, with the file and line the finding bears on, and the form the fix should take.

After a skill edit, rerun the treatment arm alone. Report the before and after counts side by side. The control counts stand until the request or fixture changes.
