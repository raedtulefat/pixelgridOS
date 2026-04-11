# .pixelgrid/augments

Purpose: project-local, user-movable augments.

## What belongs here
- Optional augments for specific workflows.
- Team/project customization.
- Augments users can copy between projects with minimal/no changes.

## Policies
- Keep augment folders self-contained.
- Prefer relative paths inside each augment.
- No hardcoded machine-specific absolute paths.
- Must be safe to enable/disable without breaking core app behavior.
- Required augments should be declared by app config, not assumed by folder contents.

## Portability goal
This path is constant across pixelgrid setups so users can move augments by copying this folder and enabling them.
