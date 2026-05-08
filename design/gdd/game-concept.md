# Game Concept: Glitch

*Created: 2026-05-09*
*Status: Draft*

## Overview

Glitch is a one-handed puzzle game where one movement rule always lies. The
player solves a small grid while testing movement hypotheses and catching the
bad rule through observation.

## Player Fantasy

Players should feel like they are outsmarting a system that is trying to cheat
them.

## Detailed Rules

- The board is a grid of simple pieces.
- Each puzzle shows movement rules.
- One rule is false.
- Swipes move pieces according to the current puzzle rules.
- Unexpected motion is information, not failure.
- The puzzle ends when the board is solved and the lie has been identified.

## Formulas

- `moves_to_catch_lie = number_of_swipes_before_the_false_rule_is_identified`
- `puzzle_score = max(0, target_moves - moves_to_catch_lie)`

## Edge Cases

- If a swipe has no valid move, it should still reveal the board state clearly.
- If the lie is obvious too early, the puzzle should escalate complexity in later levels.
- If a player makes the correct solve without identifying the lie, the end screen should still reveal the lie.

## Dependencies

- Grid movement system
- Puzzle rule system
- Lie detection system
- Score tracking system
- UI display system

## Tuning Knobs

- Grid size
- Number of rules shown
- How often the lie manifests
- Hint frequency
- Scoring thresholds

## Acceptance Criteria

- Players can complete a puzzle by swiping one-handed.
- Each puzzle contains exactly one false rule.
- Unexpected board behavior is readable and consistent.
- Completion feedback reveals both the solution and the lie.

