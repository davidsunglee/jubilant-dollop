# Dynamic Title Screen Design

## Goal

Replace the static gradient + floating cloud background on the title screen with a live, parallax-scrolling environment that changes randomly each time the player visits.

## Current State

The title screen uses `MenuBackgroundView(tint: .neutral)` — a soft pastel sky gradient (blue to pale blue-white to warm cream) with 6 barely-visible drifting cloud ellipses. Title text and buttons fade in with simple entrance animations.

## Design

### New: `TitleBackgroundScene` (SKScene)

- On `didMove(to:)`, picks a random `GameEnvironment` from `GameEnvironment.allCases`
- Uses the environment's `renderer.buildPreviewBackground(scene:size:parallax:)` to set up parallax-scrolling background layers with all environment-specific animated elements (snowflakes, fireflies, bubbles, shooting stars, etc.)
- Adds ground tiles at the bottom as a 1.0x parallax layer
- No obstacles rendered — background scenery and ground only
- No character rendered — avoids the uncanny effect of a character ignoring obstacles
- Runs at 30 FPS (smoother than 15 FPS preview cards, lighter than 60 FPS gameplay)

### Modified: `TitleView`

- Replaces `MenuBackgroundView(tint: .neutral)` with a `SpriteView` hosting `TitleBackgroundScene`
- Adds a `Color.black.opacity(0.25)` scrim overlay between the SpriteKit scene and UI elements for readability
- Title text, buttons, entrance animations, and `GlassButtonStyle` remain unchanged
- Glass buttons naturally pick up environment colors through their `.ultraThinMaterial` blur

### New: `TitleBackgroundSceneHolder` (ObservableObject)

- Wraps the `TitleBackgroundScene` instance to prevent SwiftUI from recreating it on body re-evaluation
- Same pattern as existing `EnvironmentPreviewSceneHolder`
- Pauses scene on `onDisappear`, resumes on `onAppear`

## What Stays the Same

- Character selection and environment selection screens keep `MenuBackgroundView`
- Title text styling (56pt bold rounded white with drop shadow)
- Button styling (`GlassButtonStyle` with green/orange accents)
- Entrance animations (title slides up + fades in, buttons fade in with delay)
- No new assets — all rendering uses existing `EnvironmentRenderer` implementations

## User Experience

Each visit to the title screen presents a different living world as the backdrop — an icy landscape with drifting snowflakes, a deep ocean with rising bubbles, a starfield with twinkling stars and shooting stars, etc. The effect is lively and playful, giving the player a taste of the variety available in the game.
