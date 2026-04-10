# Implement turn progression rule
Description  
Turn number is the score; it should advance correctly only when the player survives.  
Acceptance criteria  
- New run starts with `turn = 1`  
- When a card resolves and player survives (`hp > 0`), `turn` increments by 1 and next card becomes current  
- If resolving a card causes death (`hp <= 0`), `turn` does not increment


---
## Done
- Implemented `advanceTurn()` rule:
  - If alive: increment `turn`, shift `nextCard` -> `currentCard`, draw a new `nextCard`
  - If dead: do not advance or increment

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅ (added `test/rules/advance_turn_test.dart`)
