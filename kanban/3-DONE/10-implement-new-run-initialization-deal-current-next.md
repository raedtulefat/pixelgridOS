# Implement new run initialization (deal current + next)
Description  
Make a clean “start run” function that fully resets the run.  
Acceptance criteria  
- `startNewRun()` sets: `hp=startingHp`, `maxHp=maxHp`, `turn=1`, `hasSword=false`, `hasShield=false`, `isDead=false`  
- It draws `currentCard` and `nextCard` immediately  
- No leftover UI state (card positions reset)


---
## Done
- Added `startNewRun()` that fully resets a run and immediately deals `currentCard` + `nextCard`.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅ (added `test/run/start_new_run_test.dart`)
