# Create hardcoded card catalog (no assets)
Description  
Create an in-code catalog with exactly 1 example card per category/type needed for playtest.  
Acceptance criteria  
- Hardcoded cards exist in code (no JSON/assets) for:  
  - Enemy: Rat  
  - Consumable: Health Potion  
  - Gear: Sword  
  - Gear: Shield  
- Each card has a stable `id` string (e.g., `enemy_rat`, `consumable_health_potion`, etc.)


---
## Done
- Added an in-code MVP card catalog (no JSON/assets yet) with stable ids:
  - Enemy: Rat (`enemy_rat`)
  - Consumable: Health Potion (`consumable_health_potion`)
  - Gear: Sword (`gear_sword`)
  - Gear: Shield (`gear_shield`)

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅ (added `test/cards/card_catalog_test.dart`)
