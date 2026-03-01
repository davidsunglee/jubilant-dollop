# UI Polish Design

## Goal
Add visual polish to the title screen, character selection, and environment selection screens with a clean, modern aesthetic. Also add back navigation between screens.

## Approach
Purely SwiftUI — a shared `MenuBackgroundView` component with gradient + floating elements, glass-morphism cards/buttons, and subtle entrance animations. No SpriteKit in menus.

---

## MenuBackgroundView (shared component)

**Gradient:** `LinearGradient` top-to-bottom, 3 stops:
- Top: soft sky blue `(0.55, 0.78, 0.95)`
- Middle: light white-blue `(0.85, 0.92, 0.98)`
- Bottom: warm peach `(0.98, 0.90, 0.85)`

**Floating elements:** 5-7 translucent `Ellipse` shapes, 40-120pt, white at 10-20% opacity with blur. Each floats independently with slow `repeatForever` animations (8-15s random durations). Positions randomized on appear.

**Per-screen tint:** Optional parameter slightly shifts gradient hue — title is neutral, character select slightly cooler, environment select slightly warmer.

---

## Title Screen

- **Title:** "Flappy Bird" at 56pt (up from 48pt), `.rounded` font, white with soft shadow. Fade-in + slide-up animation (0.6s ease-out, 20pt travel).
- **Buttons:** Glass-morphism style:
  - `.ultraThinMaterial` background with white overlay at 30% opacity
  - 16pt corner radius
  - Soft shadow: `black.opacity(0.1), radius: 8, y: 4`
  - Text uses accent color (green for "1 Player", orange for "2 Players") instead of white-on-color
  - Press state: scale to 0.96 with spring animation
  - Staggered fade-in: buttons appear 0.2s after title

---

## Character Selection Screen

- **Back button:** `chevron.left` in top-left, circular `.ultraThinMaterial` background (36pt). Navigates to title.
- **Header:** "Select Character(s)" slides in from top with fade (0.4s).
- **Character cards:**
  - `.ultraThinMaterial` background
  - Shadow: `black.opacity(0.08), radius: 6, y: 3`
  - 16pt corner radius
  - Preview: 60x60pt, name in `.caption.bold()`
- **Selected state:**
  - Scale up to 1.05x with spring animation
  - Blue glow shadow (30% opacity, radius 12) behind card
  - Blue tint overlay on material background
- **Continue button:** Glass-morphism style, green accent text. Fades in after selection.
- **Card entrance:** Staggered fade-in, 0.05s delay per card.

---

## Environment Selection Screen

- **Back button:** Same style as character select. Navigates to character selection.
- **Header:** "Select Environment" with slide-in fade.
- **Environment cards:**
  - `.ultraThinMaterial` background
  - Shadow: `black.opacity(0.08), radius: 6, y: 3`
  - 16pt corner radius
  - Preview image: 160x80pt with rounded corners at top
  - Name in `.headline` below preview
- **Selected state:** Same glow + scale as character cards.
- **Start button:** Appears at bottom when environment is selected. Glass-morphism, green accent. Tapping starts the game.
- **Behavior change:** Tapping a card now selects it (instead of immediately starting). A separate "Start" button begins gameplay.
- **Card entrance:** Same stagger as character select.

---

## Navigation Changes

Add back navigation to `GameRouter`:
- `.characterSelection` → back → `.title`
- `.environmentSelection` → back → `.characterSelection`
- Environment select now requires explicit "Start" tap to begin game

---

## Screen Transitions

Extend crossfade to 0.4s with `.easeOut`. Per-element entrance animations (title slide, card stagger) layer on top for a composed reveal effect.
