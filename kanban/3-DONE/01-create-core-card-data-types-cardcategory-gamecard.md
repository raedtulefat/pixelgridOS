# Create core card data types (CardCategory, GameCard)
Description  
Add the basic models needed to represent a card in code, without assets.  
Acceptance criteria  
- `CardCategory` enum exists (at minimum: `enemy`, `consumable`, `gear`)  
- `GameCard` model exists with fields: `id`, `category`, `name`  
- A helper getter exists to render display text exactly like: `"Enemy: Rat"` / `"Consumable: Health Potion"` / `"Gear: Sword"`


---
## Done
- Implemented `CardCategory` enum (`enemy`, `consumable`, `gear`) and `GameCard` model (`id`, `category`, `name`).
- Added `GameCard.displayText` to render exactly: `"Enemy: Rat"`, `"Consumable: Health Potion"`, `"Gear: Sword"`.

### Test evidence
- `flutter test`
  - ✅ All tests passed (added `test/models/game_card_test.dart`).
