# Fake Pixels Multi-Layer Execution Plan (Stage Base + Stage UI)

Goal: introduce a structured source-layer stack **below** `fake_pixels` so we can render/compose:
1. `stage.base` (background/floors/content base)
2. `stage.ui` (UI visuals that should still activate fake pixels)

while keeping `fake_pixels` as the final visible renderer.

---

## Success Criteria

- `fake_pixels` output remains top visual layer.
- Source stack supports at least `stage.base` and `stage.ui`.
- Per-cell overlap is deterministic:
  1) higher priority wins, 2) if same priority, later layer in list wins.
- Layer metadata supports: `id`, `group`, `visible`, `priority`, position/scale/mirror.
- Existing logo scenario still works after migration.
- No regressions in current controls (zoom/pan/reset, settings persistence, grid settings, assets tab).
- Analyzer passes for modified files.

---

## Constraints / Non-Goals

- Do **not** split stage into a separate Flutter renderer now.
- Keep current stage transform approach internal to fake-pixels engine.
- Do not redesign the whole settings UX; add only what is necessary for operability.

---

## Phase 0 — Baseline & Safety

- [ ] Create a branch: `feature/fake-pixels-multilayer`.
- [ ] Snapshot current behavior (short QA notes + optional screenshots):
  - [ ] Logo rendering
  - [ ] Stage zoom/pan controls
  - [ ] Pix settings (res/shades/grid width/gestures)
  - [ ] Asset selection persistence
- [ ] Record files currently participating in fake-pixels flow (for regression checklist).

Deliverable: baseline notes committed to `tilldone/`.

---

## Phase 1 — Data Model Upgrade (No Behavior Change First)

### 1.1 Extend layer model

- [ ] Update `FakePixelsLayer` in `lib/fake_pixels/fake_pixels_engine.dart`:
  - [ ] `id: String`
  - [ ] `group: String` (or enum-like string constants)
  - [ ] `visible: bool` (default `true`)
  - [ ] keep existing: `assetPath`, `priority`, `mirroredX`, `stagePosition`, `stageScale`

### 1.2 Add group constants

- [ ] Add canonical layer groups in a shared place (recommended `fake_pixels_config.dart`):
  - [ ] `stage.base`
  - [ ] `stage.ui`
  - [ ] (optional reserved) `stage.content`, `stage.debug`

### 1.3 Keep backward compatibility

- [ ] Ensure defaults preserve old behavior if only one layer is configured.

Deliverable: compile-safe model upgrade with no visual change.

---

## Phase 2 — Engine Layer Processing Rules

### 2.1 Visibility filtering

- [ ] In render sample collection, skip layers where `visible == false`.

### 2.2 Deterministic overlap ordering

- [ ] Confirm and enforce ordering:
  - [ ] sort by `priority` ascending
  - [ ] preserve stable tie-break by list order (later wins)
- [ ] Add inline comments documenting this rule.

### 2.3 Stage transform compatibility

- [ ] Verify `setStageTransform(...)` affects all source layers consistently.

Deliverable: multi-layer renderer behavior deterministic and documented.

---

## Phase 3 — Config Migration to Multi-Layer

### 3.1 Default config structure

- [ ] Update `lib/fake_pixels/fake_pixels_config.dart` to define explicit layers:
  - [ ] one default base layer (`stage.base`)
  - [ ] one default ui layer (`stage.ui`) (can start disabled if no asset exists)
- [ ] Assign IDs and priorities:
  - [ ] base around `10`
  - [ ] ui around `210`

### 3.2 Runtime initialization

- [ ] Ensure `ShellOsImpl` still calls `setLayers(...)` with migrated config.

Deliverable: project starts with explicit multi-layer schema active.

---

## Phase 4 — Asset Selection Plumbing (Base/UI aware)

### 4.1 Catalog expansion

- [ ] Extend asset catalog logic to support multiple selectable targets (at minimum base + ui).
- [ ] Keep existing fallback behavior (`...1` preferred) for each target.

### 4.2 Settings keys

- [ ] Add persistent keys for each layer asset selection:
  - [ ] e.g. `fakePixelsBaseAsset`
  - [ ] e.g. `fakePixelsUiAsset`

### 4.3 Settings load/apply

- [ ] Update `menu_overlay` settings application flow:
  - [ ] read persisted base/ui asset values
  - [ ] validate against available options
  - [ ] fallback if missing
  - [ ] apply to matching layer IDs

Deliverable: base and ui layer assets are independently configurable + persisted.

---

## Phase 5 — Layer Runtime Controls (Minimal Required)

### 5.1 OS API surface

- [ ] Add methods in `ShellOsImpl` to update a layer by `id`:
  - [ ] set asset
  - [ ] set visibility
  - [ ] set priority (optional, if needed now)

### 5.2 Optional settings toggles

- [ ] Add Pix/Assets controls only if required for immediate use:
  - [ ] `stage.ui` visibility toggle (ON/OFF)
  - [ ] `stage.ui` asset selector

Deliverable: enough runtime control to actually use the new `stage.ui` layer.

---

## Phase 6 — QA / Validation

### Functional QA

- [ ] Base-only scenario: works exactly as current single-layer behavior.
- [ ] Base + UI overlap scenario: UI layer wins where overlapping.
- [ ] Toggle `stage.ui` visibility OFF: only base contributes.
- [ ] Toggle `stage.ui` visibility ON: contribution returns.
- [ ] Zoom/pan/reset still modify stage transform correctly.
- [ ] `+/-` stage zoom controls still work.
- [ ] Pixel-size `+/-` controls still update and persist.
- [ ] Assets tab selections persist and reload correctly.

### Technical QA

- [ ] `flutter analyze` passes for all modified files.
- [ ] No new warnings from imports/types.
- [ ] No crashes when configured asset is missing.

Deliverable: QA checklist signed off in commit message / PR notes.

---

## Phase 7 — Documentation & Handoff

- [ ] Update `tilldone/` with:
  - [ ] implemented architecture summary
  - [ ] final layer schema and priority rules
  - [ ] how to add new layers/assets
- [ ] Add brief dev notes near engine/config code.

Deliverable: future contributors can extend layer stack without rediscovery.

---

## Suggested File Touch Order (Most Efficient)

1. `lib/fake_pixels/fake_pixels_engine.dart` (model + render rules)
2. `lib/fake_pixels/fake_pixels_config.dart` (default schema)
3. `lib/os/internal/shell_os_impl.dart` (runtime API + apply)
4. `lib/fake_pixels/logo_asset_catalog.dart` (asset discovery updates)
5. `lib/settings/settings_keys.dart`
6. `lib/menus/menu_overlay.dart` (load/save/apply)
7. `lib/menus/settings_menu.dart` (UI controls)
8. `pubspec.yaml` only if new asset folders are introduced
9. `tilldone/*` docs + QA notes

---

## Risks & Mitigations

- Risk: tie-break ordering bugs in overlaps
  - Mitigation: explicit stable sort + test scene with equal priority layers.
- Risk: settings migration breaks existing saved logo setting
  - Mitigation: read old key as fallback into new base key for one release.
- Risk: UI complexity creep
  - Mitigation: ship minimal controls first (asset + visible).

---

## Definition of Done

- [ ] Layer model includes `id/group/visible` and is in use.
- [ ] At least two active source layers (`stage.base`, `stage.ui`) are supported.
- [ ] Overlap rule works and is documented.
- [ ] Config + persistence + UI can select assets per layer.
- [ ] Existing fake-pixels workflows remain intact.
- [ ] Analyzer clean, docs updated.
