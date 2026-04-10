# Implement rules: apply a swipe decision to a card
Description  
Create the core “engine” function that takes (state + card + left/right) and returns updated state.  
Acceptance criteria  
- Enemy: Rat  
  - Right (Fight): HP decreases by `ratFightDamage`  
  - Left (Run): HP decreases by `ratRunDamage`  
- Consumable: Health Potion  
  - Right (Drink): HP increases by `potionHeal` but capped at `maxHp`  
  - Left (Discard): no change  
- Gear: Sword  
  - Right (Equip): `hasSword = true`  
  - Left (Ignore): no change  
- Gear: Shield  
  - Right (Equip): `hasShield = true`  
  - Left (Ignore): no change


---
## Done
- Implemented `applySwipeDecision(state, card, left/right)` engine rule for MVP cards:
  - Rat: fight/run damage
  - Potion: heal (capped) / discard
  - Sword/Shield: equip on right / ignore on left

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅ (added `test/rules/apply_swipe_decision_test.dart`)
