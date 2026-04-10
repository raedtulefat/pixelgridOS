# Add swipe direction + decision mapping (Left/Right only)
Description  
Define what directions count as a “decision” for MVP (use horizontal swipes).  
Acceptance criteria  
- `SwipeDecision` enum exists with values: `left`, `right`  
- Current card drag can still move freely, but only left/right past threshold will resolve  
- Up/down drag always snaps back (no effect)


---
## Done
- Added `SwipeDecision` enum with values `left`, `right`.
- Updated swipe resolve logic so only **left/right** swipes (or horizontal overhang) resolve; vertical (up/down) drags always return/snap back.

### Test evidence
- `flutter analyze` ✅ (no issues)
- `flutter test` ✅ (added `test/input/swipe_decision_test.dart`)
