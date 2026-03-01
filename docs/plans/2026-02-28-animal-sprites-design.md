# Animal Sprite Redesign

## Problem

All 6 characters render as colored blobs (circles/rectangles) with a small SF Symbol overlay and a generic wing ellipse. They don't look like the animals they represent.

## Solution

Replace the single generic renderer with per-character builder methods that construct each animal from multiple SKShapeNodes. Drop SF Symbols entirely. Give each animal unique wing shapes and animations.

## Architecture

`CharacterRenderer.createNode(for:)` switches to dedicated private builders:

- `buildAvian()` / `buildWingedPig()` / `buildFlyingSquirrel()` / `buildPegasus()` / `buildWingedTurtle()` / `buildBat()`

Each returns an SKNode container (named `"characterVisual"`) with sub-shape children. The wing node keeps the name `"wing"` for compatibility with `PlayerNode.die()`.

The `createSymbolNode` method and `sfSymbolName` property are removed.

## Character Designs

**Avian** -- Round yellow body, orange triangular beak (right side), white eye with black pupil, feathered tail (2-3 small ellipses, left side), feathered wing ellipse.

**Winged Pig** -- Rounded pink rectangle body, circular lighter-pink snout with two dot nostrils, triangular ears on top, curly tail (left side), beady eyes, comically small wings.

**Flying Squirrel** -- Wide brown ellipse body (horizontal), small rounded head (right), big round eyes, bushy tail curving up (left), membrane-style flat wings that stretch/contract.

**Pegasus** -- White rectangular body, elongated head/neck (up-right), pointed ears, flowing multi-shape tail (left), large angelic wings with wide flap arc.

**Winged Turtle** -- Green semi-circular shell (dome top, flat bottom), small head poking out (right), stubby legs (bottom), tiny tail (left), absurdly small wings flapping frantically.

**Bat** -- Dark grey inverted-triangle body, large pointed ears on top, tiny eyes, no visible tail, large angular membrane wings (triangular) with wide flap range.

## Wing Animations

| Character | Shape | Range | Speed | Style |
|-----------|-------|-------|-------|-------|
| Avian | Feathered ellipse | 6pt | 0.15s/stroke | Smooth |
| Winged Pig | Tiny ellipse | 4pt | 0.12s/stroke | Frantic buzz |
| Flying Squirrel | Flat membrane | 3pt | 0.25s/stroke | Gentle glide |
| Pegasus | Large swept ellipse | 10pt | 0.2s/stroke | Majestic sweep |
| Winged Turtle | Comically small ellipse | 5pt | 0.08s/stroke | Desperate flutter |
| Bat | Angular triangle | 8pt | 0.18s/stroke | Sharp angular |

## Character Selection Screen

Replace `Image(systemName:)` with rendered snapshots of the actual composite sprites.

Add `CharacterRenderer.renderToImage(for:size:)` that:
1. Creates the composite SKNode via the builder
2. Renders into an off-screen SKScene
3. Captures to UIImage (iOS) / NSImage (macOS) via `SKView.texture(from:)`

Remove `sfSymbolName` from `GameCharacter` enum.

## Files Changed

- `CharacterRenderer.swift` -- rewrite with per-character builders, add renderToImage
- `GameCharacter.swift` -- remove sfSymbolName property
- `CharacterSelectionView.swift` -- replace SF Symbol icons with rendered sprite images
