# Define gameplay constants (MVP tuning in one place)
Description  
Centralize numbers so we can tweak balance without hunting through UI code.  
Acceptance criteria  
- Constants exist for: `startingHp = 10`, `maxHp = 10`, `ratFightDamage = 2`, `ratRunDamage = 1`, `potionHeal = 3`  
- Changing constants changes gameplay without refactoring other files


---
## Done
- Centralized MVP tuning numbers in `GameplayConstants`.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅ (added `test/run/gameplay_constants_test.dart`)
