# Card Selection Indicator Enhancement

**Date:** 2026-03-03
**Status:** Approved

## Problem

Selected cards on both the character selection and environment selection screens are hard to distinguish. The current indicators (a subtle blue glow at 0.3 opacity and a 5% scale-up) are too understated, especially on initial load where a default selection exists.

## Approach

Enhance the existing visual pattern (Approach A: Enhanced Glow + Border) with slight dimming of unselected cards. Stays within the glassmorphic aesthetic while making selection clearly visible.

## Design

### Selected Card

| Property           | Current                  | New                          |
|--------------------|--------------------------|------------------------------|
| Glow shadow opacity| 0.3                      | 0.5                          |
| Glow shadow radius | 12                       | 16                           |
| Border stroke      | none (clear)             | blue.opacity(0.6), 2.5pt    |
| Scale effect       | 1.05                     | 1.05 (unchanged)             |

### Unselected Card

| Property | Current | New  |
|----------|---------|------|
| Opacity  | 1.0     | 0.7  |

### Animation

All changes animated with existing spring animation (`.spring(response: 0.3, dampingFraction: 0.7)`).

### Scope

- `CharacterSelectionView.swift` — character card grid
- `EnvironmentSelectionView.swift` — environment card grid
- Same values applied to both screens for consistency.
