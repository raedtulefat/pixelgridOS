# Add a simple swipe instruction line on the gameplay screen
Description  
Make the playtest self-explanatory without a tutorial.  
Acceptance criteria  
- A small text hint is visible (example): `Swipe ← Run/Skip | Swipe → Take/Fight`  
- Hint does not block card interaction  
- Hint can be removed later without affecting gameplay logic

---
## Done
- Added a small, non-interactive swipe hint line on the gameplay screen.
- Implemented as UI-only (can be removed later without affecting gameplay logic).

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
