# Define RunState (single source of truth for gameplay)
Description  
Add a run state model that contains everything needed to play a run.  
Acceptance criteria  
- RunState includes: `hp`, `maxHp`, `turn`, `currentCard`, `nextCard`, `hasSword`, `hasShield`, `isDead`  
- RunState supports updates cleanly (copyWith or immutable pattern)


---
## Done
- Added `RunState` model with fields: `hp`, `maxHp`, `turn`, `currentCard`, `nextCard`, `hasSword`, `hasShield`.
- Added computed `isDead` getter.
- Added `copyWith(...)` for clean immutable updates.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅ (added `test/run/run_state_test.dart`)
