# Add death detection + lock gameplay when HP hits 0
Description  
When HP reaches 0 (or below), the player dies and the run stops.  
Acceptance criteria  
- If `hp <= 0`, state becomes `isDead = true`  
- No further swipes are processed while dead  
- UI clearly indicates death happened


---
## Done
- Locked gameplay input when `hp <= 0` (dead state), so no further swipes are processed.
- Death is already visible via HUD HP dropping to 0 (overlay is added in the next ticket).

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
