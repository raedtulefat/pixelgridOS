# Add GameController / State holder (connect engine to UI)
Description  
Create a controller that exposes RunState to the UI and provides actions.  
Acceptance criteria  
- UI can read current RunState reactively  
- Controller exposes: `startNewRun()`, `resolveCurrentCard(SwipeDecision)`, `restartRun()`  
- All gameplay updates happen through controller (not inside widgets)


---
## Done
- Added `GameController` that exposes reactive `RunState` and actions:
  - `startNewRun()`
  - `resolveCurrentCard(SwipeDecision)`
  - `restartRun()`
- Centralized gameplay updates inside the controller (engine rules + turn advance).

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅ (added `test/game/game_controller_test.dart`)

### Follow-up fix
- Fixed a naming collision between the controller method `startNewRun()` and the run initializer function `startNewRun(...)` by importing the initializer as `run_init.startNewRun(...)`.
- Re-verified: `flutter analyze` ✅ and `flutter test` ✅
