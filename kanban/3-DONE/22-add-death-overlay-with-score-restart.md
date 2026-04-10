# Add death overlay with score + Restart
Description  
Give a minimal “you died” experience so playtests can restart quickly.  
Acceptance criteria  
- Overlay appears when `isDead == true`  
- Overlay shows: `You died` and `Score: <turn>`  
- Overlay has a `Restart` button that starts a fresh run immediately


---
## Done
- Added a death overlay when `isDead == true`.
- Overlay shows "You died" and "Score: <turn>".
- Overlay includes a `Restart` button that starts a new run immediately.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
