# PixelGrid ↔ Canvas Architecture Split Plan

Objective: create a real boundary between:
1. **PixelGrid platform** (engine + AI/pi integration + control/runtime infrastructure)
2. **Canvas app** (the user-built application logic and UI)

Key naming changes requested:
- Replace **OS** concept with **Canvas** for user app code.
- Rename platform menu overlay from `menu_overlay` to **`control_center`**.

---

## Target Architecture

## A) PixelGrid Platform (framework/runtime)
Owns:
- fake_pixels engine and rendering internals
- settings persistence + feature toggles
- control center UI (platform controls, debugging, layer controls)
- augment system, ai/pi integration, extension hooks
- app bootstrapping + runtime event loop

Must NOT contain user app/domain logic.

## B) Canvas App (user product)
Owns:
- user screens and workflows
- user app state
- user navigation / user-facing menu
- app-specific assets and behavior

Must NOT depend on platform internals beyond public APIs.

---

## Proposed Directory Contract

### Platform
- `lib/pixelgrid/` (new namespace; preferred)
  - `fake_pixels/`
  - `control_center/`
  - `settings/`
  - `runtime/` (input, composition, host loop)
  - `augments/` (platform-side loading/runtime)

### Canvas
- `lib/canvas/` (user app root)
  - `internal/` (optional)
  - `features/`
  - `ui/`
  - `state/`
  - `assets references/config`

### Transitional note
Current code has `lib/os/` for app logic. Migrate this to `lib/canvas/` and fully remove `os` naming.

---

## Naming Migration Map

- `ShellOsImpl` / `PixelGridOsImpl` style app host naming
  - split into:
    - `PixelGridRuntimeHost` (platform)
    - `CanvasController` / `CanvasApp` (user app)
- `menu_overlay.dart` → `control_center_overlay.dart` (or `control_center.dart`)
- `SettingsMenu` under platform control center namespace
- Public app class naming:
  - `CanvasApp` for user app root
  - Platform should compose it, not own user features directly

---

## Execution Plan (Ordered)

## Phase 0 — Guardrails First

- [x] Create `ARCHITECTURE.md` defining platform/canvas boundary rules.
- [x] Add import boundary policy:
  - [x] Canvas cannot import from `pixelgrid/internal/*`.
  - [x] Platform cannot import canvas feature internals except through explicit interface.
- [x] Add temporary TODO markers for violations.

Deliverable: explicit boundary contract before moving files.

---

## Phase 1 — Introduce Canvas Namespace

- [x] Create `lib/canvas/` root.
- [x] Move user-app code from `lib/os/` into `lib/canvas/`.
- [x] Rename files/classes/symbols from `os` to `canvas` where app-facing.
- [x] Preserve old exports with compatibility aliases for one migration step.

Deliverable: user app code resides in `lib/canvas/*` with working build.

---

## Phase 2 — Introduce PixelGrid Namespace

- [x] Create `lib/pixelgrid/` root.
- [x] Move platform-owned modules under this namespace:
  - [x] fake_pixels
  - [x] settings
  - [x] control center (new)
  - [x] runtime host wiring
- [x] Replace direct cross-folder imports with platform public exports.

Deliverable: clear platform package-like namespace.

---

## Phase 3 — Control Center Rename

- [x] Rename `menus/menu_overlay.dart` → `pixelgrid/control_center/control_center_overlay.dart`.
- [x] Rename symbols:
  - [x] `MenuOverlay` → `ControlCenterOverlay`
  - [x] related private widget names where needed
- [x] Keep behavior identical in this phase (rename-only).

Deliverable: naming aligned with platform role.

---

## Phase 4 — Runtime Composition Split

- [x] Create explicit composition boundary in `main.dart`:
  - [x] PixelGrid runtime host
  - [x] Canvas app entrypoint
  - [x] Control center overlay
- [x] Define a minimal interface for canvas registration (example):
  - [x] canvas render hooks / state hooks
  - [x] optional input handlers
- [x] Ensure control center interacts with platform state, not direct canvas internals.

Deliverable: platform composes canvas, not vice versa.

---

## Phase 5 — API Surface Cleanup

- [x] Add `lib/pixelgrid.dart` public facade export.
- [x] Add `lib/canvas.dart` public facade export.
- [x] Remove or deprecate old `os.dart` exports.
- [x] Ensure no `os` terminology remains in public API.

Deliverable: clean public naming and import paths.

---

## Phase 6 — Settings Ownership Clarification

- [x] Keep platform settings (fake_pixels, control center) under `pixelgrid/settings`.
- [x] Introduce separate canvas settings store namespace (if needed):
  - [x] e.g. `canvas.*` keys
- [x] Ensure platform settings schema doesn’t absorb app-specific keys.

Deliverable: settings split follows architecture split.

---

## Phase 7 — Verification

### Build/Quality
- [x] `flutter analyze` clean.
- [x] App boots with moved namespaces.
- [x] No broken imports after rename.

### Functional
- [x] fake_pixels rendering unchanged.
- [x] control center still functions.
- [x] canvas app flow still functions.

### Boundary
- [x] No direct canvas→platform internal import violations.
- [x] No platform dependency on canvas feature internals.

Deliverable: migration complete and behavior stable.

---

## Phase 8 — Remove Legacy Paths

- [x] Remove `lib/os/` and all stale aliases.
- [x] Remove temporary backward-compat exports.
- [x] Update docs/readme references from os/menu overlay to canvas/control center.

Deliverable: final architecture state with no legacy residue.

---

## Risk Register + Mitigation

- Risk: rename churn breaks many imports
  - Mitigation: staged aliases in Phase 1/2, remove in Phase 8.
- Risk: control center accidentally retains app logic
  - Mitigation: enforce platform-only ownership in code review checklist.
- Risk: hidden coupling through settings keys
  - Mitigation: key prefixing + ownership table in docs.

---

## Definition of Done

- [x] User app code is under `lib/canvas/` and uses canvas naming.
- [x] Platform code is under `lib/pixelgrid/` and uses control center naming.
- [x] `menu_overlay` concept is replaced by `control_center` naming.
- [x] No public `os` naming remains.
- [x] Runtime composition explicitly separates platform and canvas.
- [x] Analyzer clean; docs updated.
