# lib/augments

Purpose: built-in, app-shipped augments.

## What belongs here
- Core augments required by pixelgrid itself.
- Default augments maintained with app source code.
- Code that must exist in every build/environment.

## Policies
- Stable internal API contracts.
- Versioned with the app release cycle.
- Safe defaults only; avoid user-specific behavior here.
- Keep this directory portable within pixelgrid source, not between arbitrary projects.

## Notes
User/project custom augments should live in `.pixelgrid/augments` instead.
