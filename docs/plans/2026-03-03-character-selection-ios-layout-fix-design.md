# Character Selection Screen iOS Layout Fix

**Date:** 2026-03-03
**Status:** Approved

## Problem

On iOS, the character selection screen in two-player mode clips the header, back button, and continue button — all appear pushed roughly 59pt too high. Root cause: `MenuBackgroundView` applies `.ignoresSafeArea()` to its gradient and cloud views, which causes the containing `ZStack` in `CharacterSelectionView` to expand to full physical screen coordinates. All content originates at y=0 (behind the Dynamic Island / status bar) rather than within the safe area.

## Solution

### Universal fix (all devices)

Add `.safeAreaPadding()` to both the content `VStack` and the back button overlay `VStack` inside `CharacterSelectionView`. This compensates for the ZStack's full-screen expansion by explicitly pushing content below the top safe area inset and above the bottom safe area inset.

### iPhone compact + 2P mode tweaks

Guarded by `horizontalSizeClass == .compact && playerCount == 2`. Keeps 3 columns with 84pt cards, reducing surrounding chrome to recover vertical space.

| Element | Current | Proposed |
|---|---|---|
| "Select Characters" font size | 36pt | 28pt |
| VStack spacing | 20pt | 12pt |
| "Player 1" / "Player 2" font | `.title3.bold()` | `.footnote.bold()` |
| `characterPicker` inner VStack spacing | 12pt | 8pt |
| Card size | 100×100pt | 84×84pt |
| Continue button font | `.title2.bold()` | `.headline.bold()` |
| Continue button height | 50pt | 44pt |

Back button alignment is handled automatically — both it and the header share the same `.safeAreaPadding()` top offset.

iPad and macOS (regular horizontal size class) keep all original values.

## Scope

Single file: `FlappyBird/Views/CharacterSelectionView.swift`
