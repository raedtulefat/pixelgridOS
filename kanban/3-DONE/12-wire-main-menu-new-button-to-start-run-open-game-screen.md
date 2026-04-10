# Wire Main Menu “New” button to start run + open game screen
Description  
Make it possible to reach the playable loop from the existing menu.  
Acceptance criteria  
- Tapping “New” calls `startNewRun()` and navigates to the card gameplay screen  
- If already in a run, “New” still starts a fresh run


---
## Done
- Main menu "New" button already calls `game.startNewRun()`; `startNewRun()` sets game mode to `playing`, so the UI transitions into the gameplay board.
- Starting a new run always resets card positions because `_loadCardsForRun()` calls `_resetCardPositions()`.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
