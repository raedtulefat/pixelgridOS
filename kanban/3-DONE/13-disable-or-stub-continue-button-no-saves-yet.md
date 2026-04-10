# Disable or stub “Continue” button (no saves yet)
Description  
Prevent confusing dead buttons during playtest.  
Acceptance criteria  
- “Continue” is disabled OR shows a simple “Not implemented” message  
- App does not crash if tapped


---
## Done
- Disabled the "Continue" button (no saves/load implemented yet), so taps cannot crash.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
