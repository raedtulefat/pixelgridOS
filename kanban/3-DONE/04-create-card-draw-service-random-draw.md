# Create card draw service (random draw)
Description  
Implement a tiny service to return the “next” card from the hardcoded catalog.  
Acceptance criteria  
- `drawNextCard()` returns a `GameCard` from the catalog  
- It never returns `null`  
- Optional but allowed: avoid returning the same `id` twice in a row


---
## Done
- Added `CardDrawService.drawNextCard()` that returns a `GameCard` from the hardcoded catalog.
- Guaranteed non-null return (throws only if the catalog is empty).
- Avoids returning the same card `id` twice in a row.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅ (added `test/cards/card_draw_service_test.dart`)
