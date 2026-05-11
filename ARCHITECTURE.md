# PixelGrid Architecture

## Split

This repository is intentionally split into two layers:

1. **PixelGrid Platform** (`lib/pixelgrid/`)
   - fake_pixels rendering engine
   - control center UI
   - platform settings/persistence
   - runtime host and input/gesture handling
   - platform UI primitives

2. **Canvas App** (`lib/canvas/`)
   - user-app domain concepts and app-level modes/state
   - app-specific features and workflows

## Boundary Rules

- Canvas code must not import `lib/pixelgrid/**/internal` style private implementation details.
- Platform code should not depend on canvas feature internals; it composes canvas through public types/contracts.
- Control center is a platform feature, not a canvas feature.
- New user-facing app features should be added under `lib/canvas/`.
- New platform/debug/engine/tooling features should be added under `lib/pixelgrid/`.

## Naming

- Use **Canvas** for user app naming.
- Use **Control Center** for platform menu/overlay naming.
- Avoid legacy `os` and `shell` naming in new code.
