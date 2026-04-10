# Add HP + Turn HUD on gameplay screen
Description  
Display the player’s HP as a number and the current turn (score) as a number.  
Acceptance criteria  
- HUD shows `HP: <number>` and `Turn: <number>` (or similar)  
- Values update immediately after each resolved card  
- HP is shown as a plain number (no hearts required)


---
## Done
- Added a gameplay HUD overlay showing `HP: <number>` and `Turn: <number>`.
- HUD binds reactively to `game.runStateListenable` so values update immediately after each resolved card.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
