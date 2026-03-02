# Environment Grid 3-Column Layout

## Goal

Change the environment selection grid from 2 columns (3 rows) to 3 columns (2 rows) for a better landscape experience on iOS.

## Context

- The app runs in landscape-only mode
- 3 rows of 2 cards wastes horizontal space and looks cramped vertically, especially on iPhone in landscape
- 2 rows of 3 is a better use of the wide aspect ratio

## Approach: Column Count Change Only

Modify `EnvironmentSelectionView.swift` only:

1. Add a third `GridItem(.flexible())` to the `LazyVGrid` columns array (line 21-23)
2. Increase `maxWidth` from `600` to `750` so 3 cards fit comfortably on iPad/macOS

## What stays untouched

- All entrance animations (`headerVisible`, `cardsVisible`)
- Card selection animation (spring scale + blue shadow)
- `LiveEnvironmentPreview` — no changes to frame size (170x100), SpriteView, or scene holder
- ScrollView wrapper, back button, Start button
- All 6 environment renderers and `buildPreviewBackground` methods

## Risk

Extremely low. Only the grid layout declaration changes. No animation code, SpriteKit views, or constraint-sensitive code is modified.
