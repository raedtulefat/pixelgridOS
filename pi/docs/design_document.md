# SINGLE-APP OS STYLE ENVIRONMENT (IOS APP) — DESIGN DOCUMENT

## PURPOSE

Create a single iOS application that behaves like a personal operating system layer.  
The app becomes the primary interface of the device when combined with Guided Access.  
All core interactions (UI, navigation, tools, visuals) are handled inside this app.

This is NOT a real OS replacement.  
This is an app acting as an OS-like environment.

---

## CORE PRINCIPLES

- Single-entry experience (user lands here every time)
- No reliance on multiple apps
- Fully controlled UI/UX
- Expandable feature system
- Pixel-based rendering system (custom visuals)
- Works without jailbreak (phase 1)
- Future extensibility (jailbreak optional phase 2)

---

## USER FLOW

1. User unlocks device
2. Guided Access resumes app
3. App displays HOME SCREEN
4. User navigates through internal modules
5. Exit requires passcode (Guided Access)

---

## APP STRUCTURE

### 1. ROOT LAYER

Acts as the “OS shell”

Responsibilities:
- Navigation
- State management
- Module loading
- Global UI

---

### 2. HOME SCREEN

Simple menu interface

Features:
- List of modules (apps inside app)
- Minimal UI
- Fast navigation
- Keyboard / touch friendly

Example Modules:
- Pixel Canvas
- Photos Viewer
- Phone Actions
- Settings
- Experimental Features

---

## MODULE SYSTEM

Each feature is treated as a "module"

### Module Interface

Each module must define:

- `id`
- `name`
- `icon`
- `entryView`
- `permissionsRequired`

---

## CORE MODULES

### 1. PIXEL GRID ENGINE

Custom rendering system

Goal:
Simulate a fake low-resolution pixel display

#### Behavior

- Define virtual resolution (e.g. 64x64 grid)
- Each “pixel” is a block of real pixels
- Manual rendering control

#### Implementation Options

- Metal (preferred)
- Core Graphics
- SwiftUI Canvas (simpler start)

#### Features

- Turn pixels on/off
- Draw shapes
- Animate grid
- Game-ready foundation

---

### 2. PHOTOS MODULE

Access device photos

Uses:
- PhotoKit

Capabilities:
- Read photos (with permission)
- Display images
- Convert images → pixel grid (optional)

---

### 3. PHONE ACTIONS MODULE

Limited telephony access

Capabilities:
- Initiate phone calls (via URL schemes)
- Open SMS
- Cannot fully control phone system

---

### 4. CONNECTIVITY MODULE

Handles:

- Bluetooth (CoreBluetooth)
- Wi-Fi (limited control)
- Local network discovery

---

### 5. SETTINGS MODULE

Internal app settings only

Examples:
- Pixel grid size
- Theme
- Permissions status
- Debug toggles

---

## PERMISSIONS MODEL

All permissions must be explicitly requested:

- Photos
- Bluetooth
- Microphone (optional)
- Camera (optional)

Store permission state internally

---

## NAVIGATION SYSTEM

Simple stack-based navigation

- Home → Module
- Module → Subview
- Back navigation always available

---

## UI DESIGN

- Minimal
- Functional
- OS-like feel
- Fast transitions
- No heavy animations initially

---

## GUIDED ACCESS INTEGRATION

User manually enables Guided Access

Behavior:
- Locks device to this app
- Prevents exit
- Passcode required to leave

This simulates a "single OS environment"

---

## LIMITATIONS (IMPORTANT)

- Cannot replace iOS
- Cannot auto-launch on unlock (without Guided Access)
- Cannot install external apps
- Cannot access private system APIs
- No custom bootloader

---

## FUTURE PHASE (OPTIONAL - JAILBREAK)

If jailbroken:

Potential additions:
- Custom launcher behavior
- Auto-start app on unlock
- Third-party app loading system
- More system hooks

---

## INTERNAL APP STORE (SIMULATION)

Instead of real app store:

Create a "Module Store"

- Load modules dynamically
- Enable/disable modules
- Possibly download configs or scripts

---

## STATE MANAGEMENT

Global state includes:

- Active module
- User settings
- Permissions
- Pixel engine state

---

## DATA STORAGE

Use:

- UserDefaults (simple)
- CoreData / SQLite (advanced)

---

## DEVELOPMENT STACK

- Language: Swift
- UI: SwiftUI (preferred)
- Graphics: Metal / Canvas
- APIs: Apple public frameworks only

---

## INITIAL MVP

Phase 1:

- Home Screen
- Pixel Grid Module (basic)
- Settings Module
- Navigation system
- Guided Access usage

---

## EXPANSION IDEAS

- Mini games using pixel grid
- AI assistant module
- File system simulation
- Notes / tasks
- Messaging wrapper

---

## AGENT NOTES (IMPORTANT)

When analyzing or extending this system:

- Treat modules as independent apps
- Avoid reliance on iOS default UI patterns
- Prefer internal implementations over system apps
- If a feature cannot be implemented due to iOS restrictions, simulate it

---

## MEMORY RULES FOR AGENT

- Preferences stated by user must be remembered
- Technical decisions (e.g., pixel size) should be stored
- If updated later, overwrite previous values
- Questions about system design are strong signals for memory

Example:
"tile size is 32x32" → store
"change to 64x64" → update

---

## LONG-TERM VISION

A fully self-contained digital environment inside a single app  
That behaves like a simplified, customizable operating system  
Optimized for creativity, experimentation, and control