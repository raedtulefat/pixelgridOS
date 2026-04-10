# Advance the 2-card lane after resolve (next → current, draw new next)
Description  
After resolving, the preview card becomes current and a new preview card is drawn.  
Acceptance criteria  
- After resolve (and survive), right card becomes the new left card  
- A new `nextCard` is drawn and appears on the right  
- Card positions reset cleanly for the next turn


---
## Done
- After a resolve, the controller decision is applied when the resolve animation completes.
- If alive, the lane advances (`nextCard` becomes `currentCard`) and a new `nextCard` is drawn.
- Card positions reset cleanly for the next turn.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
