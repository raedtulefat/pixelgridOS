# Add in-game hamburger menu actions (Restart / Quit)
Description  
Use the existing hamburger icon to control the run during testing.  
Acceptance criteria  
- Hamburger opens a menu with: `Restart Run`, `Quit to Menu`  
- `Restart Run` resets the run (same as Restart button)  
- `Quit to Menu` returns to main menu without crashes


---
## Done
- Hamburger menu now includes:
  - `Restart Run` (starts a fresh run)
  - `Quit to Menu` (returns to main menu)

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
