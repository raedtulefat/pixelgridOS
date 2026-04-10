# Restrict dragging to the current (left) card only
Description  
Prevent the preview card from being interactable.  
Acceptance criteria  
- Only the left/current card responds to drag gestures  
- Right/next card does not move when touched  
- Current card is visually on top if overlap ever occurs


---
## Done
- Only the left/current card responds to drag gestures (pointer down ignores any non-left card).
- Preview/right card does not move when touched.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
