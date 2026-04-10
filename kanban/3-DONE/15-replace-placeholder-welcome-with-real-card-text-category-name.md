# Replace placeholder “Welcome” with real card text (category + name)
Description  
Cards should show only text: `<Category>: <Name>` for playtest.  
Acceptance criteria  
- Current card renders exactly like: `Enemy: Rat`, `Consumable: Health Potion`, `Gear: Sword`, `Gear: Shield`  
- Next card also renders its text (preview)


---
## Done
- Current card now renders `"<Category>: <Name>"` via `GameCard.displayText`.
- Next card also renders its display text as the preview.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
