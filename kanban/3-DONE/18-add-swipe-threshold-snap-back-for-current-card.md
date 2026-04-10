# Add swipe threshold + snap-back for current card
Description  
Resolve a card only when dragged far enough left or right; otherwise return to start position.  
Acceptance criteria  
- Drag release below threshold snaps back to center  
- Drag release past left threshold triggers `SwipeDecision.left`  
- Drag release past right threshold triggers `SwipeDecision.right`


---
## Done
- Added a horizontal swipe threshold for resolving the current card.
- Releases below threshold snap back to center.
- Releases past threshold trigger `SwipeDecision.left` / `SwipeDecision.right`.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅ (added `test/input/swipe_threshold_test.dart`)
