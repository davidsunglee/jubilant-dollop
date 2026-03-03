# App Icon Motion Trail Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update `scripts/generate-app-icon.swift` to draw the bird at 75% scale with a three-ellipse motion trail trailing to the left, then regenerate all icon PNGs.

**Architecture:** The icon is generated entirely by a single Swift CoreGraphics script. No Xcode changes needed — just edit the script and re-run it. The trail ellipses are drawn in canvas coordinates (outside the bird's local transform) before the bird, so the bird overlaps them naturally.

**Tech Stack:** Swift CLI script, CoreGraphics, run with `swift scripts/generate-app-icon.swift` from the project root.

---

### Task 1: Scale up the bird and shift it left

**Files:**
- Modify: `scripts/generate-app-icon.swift:96-98`

**Step 1: Update `birdScale` and `cx`**

Change these two values in the `-- Bird setup --` section:

```swift
// Before
let birdScale: CGFloat = 15.0
let cx: CGFloat = 490   // slightly left of center (beak extends right)

// After
let birdScale: CGFloat = 18.0
let cx: CGFloat = 460   // shifted further left to give trail room
```

`birdScale` going from 15 → 18 increases the body diameter from 390px to 468px (≈46% → ≈46%... no wait: 13 × 2 × 18 = 468px on 1024 = ~46%). The full bird including beak reaches to roughly cx + 20×birdScale = 460 + 360 = 820px, keeping the beak well within the right edge.

**Step 2: Run the script to verify it still generates without errors**

```bash
swift scripts/generate-app-icon.swift
```

Expected output ends with: `All icons generated successfully in FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/`

**Step 3: Open the icon to visually confirm the bird is larger**

```bash
open FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024x1024.png
```

Expected: bird is noticeably larger, more presence in frame, no clipping on any edge.

**Step 4: Commit**

```bash
git add scripts/generate-app-icon.swift
git commit -m "feat(icon): scale bird up to 75% with wider left margin"
```

---

### Task 2: Add the motion trail

**Files:**
- Modify: `scripts/generate-app-icon.swift` — add trail drawing just before `// -- Bird setup --`

**Step 1: Understand where to insert**

The trail must be drawn BEFORE the bird transform block so the bird renders on top. Insert the trail drawing block between the gradient section and `// -- Bird setup --` (currently around line 95).

**Step 2: Add the trail ellipses**

Insert this block after the gradient code and before `// -- Bird setup --`:

```swift
// -- Motion trail (drawn before bird so bird overlaps) --
// Three elongated ellipses trailing left of the bird's body.
// Bird center is at (460, 512). Body radius = 13 × 18 = 234px.
// Left edge of bird body ≈ 460 - 234 = 226px.
// Trail ellipses are centered on the bird's vertical midline (y=512).
let trailYellow = RGBA(r: 1.0, g: 1.0, b: 0.0, a: 0.40)   // 40% opacity
let trailYellow2 = RGBA(r: 1.0, g: 1.0, b: 0.0, a: 0.25)  // 25% opacity
let trailYellow3 = RGBA(r: 1.0, g: 1.0, b: 0.0, a: 0.12)  // 12% opacity

// Trail 1: closest, 85×55px, starts just off the left edge of the body
fillEllipse(ctx, center: CGPoint(x: 178, y: 512), size: CGSize(width: 85, height: 55), fill: trailYellow)
// Trail 2: middle, 60×40px, ~80px further left
fillEllipse(ctx, center: CGPoint(x: 98, y: 512), size: CGSize(width: 60, height: 40), fill: trailYellow2)
// Trail 3: farthest, 40×26px, ~70px further left
fillEllipse(ctx, center: CGPoint(x: 28, y: 512), size: CGSize(width: 40, height: 26), fill: trailYellow3)
```

Note: `fillEllipse` takes a center + size and draws at 1024 canvas coords (scale factor is only applied inside the bird's `saveGState`/`restoreGState` block, which we're outside of here).

Wait — check this: `ctx.scaleBy(x: scale, y: scale)` is called at line 86 with `scale = size / 1024.0`. At `size=1024`, scale=1.0, so no effect. These coordinates are correct as-is.

**Step 3: Run the script**

```bash
swift scripts/generate-app-icon.swift
```

Expected: same success output as Task 1.

**Step 4: Open and visually verify the trail**

```bash
open FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024x1024.png
```

Expected:
- Three fading yellow streaks trail to the left of the bird
- Trail streaks are subtle — they don't compete with the bird
- Bird overlaps the trail cleanly
- No awkward clipping at the left edge

If the trail feels too subtle or too strong, adjust the opacity values:
- Too subtle: increase `trailYellow` from 0.40 → 0.55, others proportionally
- Too strong: decrease `trailYellow` from 0.40 → 0.30, others proportionally

**Step 5: Stage the PNG assets**

```bash
git add FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/
```

**Step 6: Commit everything**

```bash
git add scripts/generate-app-icon.swift
git commit -m "feat(icon): add motion trail to convey speed and action"
```

---

### Task 3: Verify small sizes aren't broken

**Step 1: Open the 32×32 icon**

```bash
open FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/icon_32x32.png
```

Expected: bird is readable, trail is barely visible or invisible (that's fine — at small sizes the bird silhouette is what matters).

**Step 2: Open the 128×128 icon**

```bash
open FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128.png
```

Expected: trail is subtly visible, bird is larger and more dominant than before.

No code changes needed for this task — it's verification only. If small sizes look bad (e.g. trail creates visual noise), increase trail opacity contrast or reduce trail ellipse sizes in the script and re-run.
