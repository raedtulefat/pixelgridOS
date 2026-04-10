# Convert gameplay layout to “2-card lane” (current left, next right)
Description  
Keep two visible cards like current repo, but make it a real loop: left is active, right is preview.  
Acceptance criteria  
- Two cards are visible side-by-side  
- Left card = `currentCard`  
- Right card = `nextCard`  
- Layout remains stable across common screen sizes


---
## Done
- Two cards are visible side-by-side.
- Left card renders `currentCard`, right card renders `nextCard`.
- Reduced horizontal gap for better stability across common screen sizes.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
