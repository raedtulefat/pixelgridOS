# Implement gear effect on Rat fight damage (simple + visible)
Description  
Make Sword/Shield do something small so gear cards matter during playtest.  
Acceptance criteria  
- If `hasSword == true`, Rat Fight damage is reduced by 1  
- If `hasShield == true`, Rat Fight damage is reduced by 1  
- Fight damage cannot go below 1 (minimum damage = 1)


---
## Done
- Updated Rat Fight damage calculation:
  - `hasSword` reduces fight damage by 1
  - `hasShield` reduces fight damage by 1
  - Minimum fight damage is clamped to 1

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅ (added `test/rules/gear_effects_test.dart`)
