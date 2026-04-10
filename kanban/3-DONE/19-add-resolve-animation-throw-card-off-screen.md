# Add resolve animation (throw card off-screen)
Description  
Make swipes feel like a real decision: card leaves the screen in swipe direction.  
Acceptance criteria  
- On resolve, current card animates off-screen in the chosen direction  
- During animation, further input is blocked  
- Animation completes reliably without glitches


---
## Done
- Resolve already animates the current card off-screen in the chosen direction.
- Blocked further input while the resolve (flick) animation is in progress.

### Test evidence
- `flutter analyze` ✅
- `flutter test` ✅
