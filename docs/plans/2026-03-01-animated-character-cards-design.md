# Animated Character Selection Cards

## Goal

Replace static character images in the character selection screen with live animated SpriteKit previews. Characters flap their wings and bob gently inside their cards, making the selection screen feel alive.

## Approach

Embed a `SpriteView` per character card, each hosting a small `SKScene` that uses the existing `CharacterRenderer.createNode()`. Wing animations come for free from the renderer. A bobbing `SKAction` adds gentle vertical float.

## Components

### LiveCharacterPreview

New SwiftUI view wrapping a `SpriteView` with a backing `SKScene` subclass.

- **Scene**: 60x60, transparent background, `.continuous` rendering mode
- **Character node**: Created via `CharacterRenderer.createNode()`, centered in scene. Wing animations run automatically.
- **Bobbing**: `SKAction.moveBy(y: 4)` up/down with `easeInEaseOut`, ~0.75s cycle, repeating forever
- **Selected state**: Bobbing amplitude increases from 4pt to 7pt. Visual emphasis handled by existing card `scaleEffect` and glow.
- **Transparency**: `SpriteView` uses `.allowsTransparency` so card material background shows through.

### CharacterSelectionView Changes

- Replace the `CharacterRenderer.renderToImage()` call in `characterCard()` with `LiveCharacterPreview(character:isSelected:)`
- No changes to card layout, styling, grid structure, or navigation logic
- Existing entrance fade-in animation applies naturally

## Performance

- 6 scenes in single-player, 12 in two-player — each is a tiny 60x60 scene with a handful of shape nodes
- No caching needed for live scenes; existing `renderToImage` cache remains untouched for gameplay use
- `SpriteView` works on both iOS and macOS without conditional compilation

## Files

- **New**: `FlappyBird/Views/LiveCharacterPreview.swift`
- **Modified**: `FlappyBird/Views/CharacterSelectionView.swift`
