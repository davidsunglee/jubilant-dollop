# App Icon Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Generate a clean, minimal app icon featuring the Avian (yellow bird) on a sky gradient, and wire it into the iOS and macOS asset catalogs.

**Architecture:** A standalone Swift script uses CoreGraphics to draw the Avian character on a sky gradient canvas at 1024x1024, then scales it down to all required macOS sizes. The generated PNGs are placed directly into the existing `AppIcon.appiconset` and the `Contents.json` is updated to reference them.

**Tech Stack:** Swift (standalone script), CoreGraphics, ImageIO

---

### Task 1: Create the icon generator Swift script

**Files:**
- Create: `scripts/generate-app-icon.swift`

**Step 1: Create the scripts directory**

Run: `mkdir -p scripts`

**Step 2: Write the icon generator script**

Create `scripts/generate-app-icon.swift` with the following content. This script draws the Avian bird using CoreGraphics (mirroring the SpriteKit `CharacterRenderer.buildAvian()` shapes) onto a sky gradient background, exports a 1024x1024 PNG, then scales it to all required macOS sizes.

```swift
#!/usr/bin/env swift

import Foundation
import CoreGraphics
import ImageIO

#if canImport(CoreImage)
import CoreImage
#endif

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

// MARK: - Configuration

let outputDir = "FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset"
let baseSize: CGFloat = 1024

// All required icon sizes: (filename, pixel size)
let iconSizes: [(String, Int)] = [
    ("icon_1024x1024.png", 1024),    // iOS universal
    ("icon_512x512@2x.png", 1024),   // macOS 512@2x
    ("icon_512x512.png", 512),       // macOS 512@1x
    ("icon_256x256@2x.png", 512),    // macOS 256@2x
    ("icon_256x256.png", 256),       // macOS 256@1x
    ("icon_128x128@2x.png", 256),    // macOS 128@2x
    ("icon_128x128.png", 128),       // macOS 128@1x
    ("icon_32x32@2x.png", 64),      // macOS 32@2x
    ("icon_32x32.png", 32),          // macOS 32@1x
    ("icon_16x16@2x.png", 32),      // macOS 16@2x
    ("icon_16x16.png", 16),          // macOS 16@1x
]

// MARK: - Colors

struct RGBA {
    let r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat
    var cgColor: CGColor { CGColor(red: r, green: g, blue: b, alpha: a) }
}

let gradientTop = RGBA(r: 0.831, g: 0.933, b: 1.0, a: 1)       // #D4EEFF
let gradientBottom = RGBA(r: 0.992, g: 0.910, b: 0.816, a: 1)   // #FDE8D0
let birdYellow = RGBA(r: 1.0, g: 1.0, b: 0.0, a: 1)             // yellow
let birdOrange = RGBA(r: 1.0, g: 0.647, b: 0.0, a: 1)           // orange
let bellyColor = RGBA(r: 1.0, g: 1.0, b: 0.8, a: 1)             // cream
let wingGold = RGBA(r: 0.9, g: 0.8, b: 0.0, a: 0.9)             // gold
let beakStroke = RGBA(r: 0.8, g: 0.4, b: 0.0, a: 1)             // dark orange
let tailGold = RGBA(r: 0.9, g: 0.7, b: 0.0, a: 1)               // darker gold
let white = RGBA(r: 1, g: 1, b: 1, a: 1)
let black = RGBA(r: 0, g: 0, b: 0, a: 1)
let darkGray = RGBA(r: 0.33, g: 0.33, b: 0.33, a: 1)
let shadowColor = RGBA(r: 0, g: 0, b: 0, a: 0.05)

// MARK: - Drawing Helpers

func fillEllipse(_ ctx: CGContext, center: CGPoint, size: CGSize, fill: RGBA, stroke: RGBA? = nil, lineWidth: CGFloat = 0) {
    let rect = CGRect(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    ctx.saveGState()
    ctx.setFillColor(fill.cgColor)
    ctx.fillEllipse(in: rect)
    if let stroke = stroke, lineWidth > 0 {
        ctx.setStrokeColor(stroke.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.strokeEllipse(in: rect)
    }
    ctx.restoreGState()
}

func fillCircle(_ ctx: CGContext, center: CGPoint, radius: CGFloat, fill: RGBA, stroke: RGBA? = nil, lineWidth: CGFloat = 0) {
    fillEllipse(ctx, center: center, size: CGSize(width: radius * 2, height: radius * 2), fill: fill, stroke: stroke, lineWidth: lineWidth)
}

// MARK: - Draw Icon at 1024x1024

func drawIcon(size: CGFloat) -> CGImage? {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let s = Int(size)
    guard let ctx = CGContext(data: nil, width: s, height: s, bitsPerComponent: 8, bytesPerRow: 0,
                               space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        return nil
    }

    // Scale factor: all coordinates are designed for 1024, scale to actual size
    let scale = size / 1024.0
    ctx.scaleBy(x: scale, y: scale)

    // -- Background gradient --
    let gradientColors = [gradientTop.cgColor, gradientBottom.cgColor] as CFArray
    let locations: [CGFloat] = [0.0, 1.0]
    guard let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: locations) else { return nil }
    // CoreGraphics origin is bottom-left, so bottom color at y=0, top at y=1024
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 512, y: 1024), end: CGPoint(x: 512, y: 0), options: [])

    // -- Bird setup --
    // Center the bird, apply ~10 degree upward tilt
    // SpriteKit Avian body radius = 13, total span ~40 units. Scale up to fill ~60% of icon.
    // Icon is 1024, we want bird ~620px wide. Original bird span is ~40, so birdScale ~15.
    let birdScale: CGFloat = 15.0
    let cx: CGFloat = 490   // slightly left of center (beak extends right)
    let cy: CGFloat = 512   // vertical center

    ctx.saveGState()
    ctx.translateBy(x: cx, y: cy)
    ctx.scaleBy(x: birdScale, y: birdScale)
    ctx.rotate(by: 10 * .pi / 180)  // 10 degree upward tilt

    // -- Drop shadow (draw a slightly offset, blurred dark ellipse behind body) --
    fillCircle(ctx, center: CGPoint(x: 0, y: -3), radius: 14, fill: shadowColor)

    // -- Tail feathers --
    for i in 0..<2 {
        let yOff = CGFloat(i) * 4 - 2
        let angle = CGFloat(i) * 0.3 - 0.15
        ctx.saveGState()
        ctx.translateBy(x: -14, y: yOff)
        ctx.rotate(by: angle)
        fillEllipse(ctx, center: .zero, size: CGSize(width: 10, height: 4), fill: tailGold, stroke: birdOrange, lineWidth: 0.5)
        ctx.restoreGState()
    }

    // -- Body --
    fillCircle(ctx, center: .zero, radius: 13, fill: birdYellow, stroke: birdOrange, lineWidth: 1.5)

    // -- Belly --
    fillEllipse(ctx, center: CGPoint(x: 1, y: -2), size: CGSize(width: 16, height: 12), fill: bellyColor)

    // -- Wing (mid-flap, angled up) --
    ctx.saveGState()
    ctx.translateBy(x: -4, y: 6)
    ctx.rotate(by: 0.2)  // slight upward angle for mid-flap
    fillEllipse(ctx, center: .zero, size: CGSize(width: 14, height: 8), fill: wingGold, stroke: birdOrange, lineWidth: 0.5)
    ctx.restoreGState()

    // -- Eye --
    fillCircle(ctx, center: CGPoint(x: 6, y: 4), radius: 4, fill: white, stroke: darkGray, lineWidth: 0.5)

    // -- Pupil --
    fillCircle(ctx, center: CGPoint(x: 7, y: 4), radius: 2, fill: black)

    // -- Beak --
    ctx.saveGState()
    ctx.setFillColor(birdOrange.cgColor)
    ctx.setStrokeColor(beakStroke.cgColor)
    ctx.setLineWidth(1)
    ctx.beginPath()
    ctx.move(to: CGPoint(x: 12, y: 2))
    ctx.addLine(to: CGPoint(x: 20, y: 0))
    ctx.addLine(to: CGPoint(x: 12, y: -2))
    ctx.closePath()
    ctx.drawPath(using: .fillStroke)
    ctx.restoreGState()

    ctx.restoreGState()  // undo bird transform

    return ctx.makeImage()
}

// MARK: - Scale and Export

func savePNG(_ image: CGImage, to path: String) -> Bool {
    let url = URL(fileURLWithPath: path)
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else {
        return false
    }
    CGImageDestinationAddImage(dest, image, nil)
    return CGImageDestinationFinalize(dest)
}

func scaleImage(_ image: CGImage, to size: Int) -> CGImage? {
    if image.width == size && image.height == size { return image }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                               space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        return nil
    }
    ctx.interpolationQuality = .high
    ctx.draw(image, in: CGRect(x: 0, y: 0, width: size, height: size))
    return ctx.makeImage()
}

// MARK: - Main

let fileManager = FileManager.default

// Ensure output directory exists
if !fileManager.fileExists(atPath: outputDir) {
    try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
}

// Draw the base 1024x1024 icon
guard let baseImage = drawIcon(size: 1024) else {
    print("ERROR: Failed to draw base icon")
    exit(1)
}

print("Generated base 1024x1024 icon")

// Export all sizes
var success = true
for (filename, pixelSize) in iconSizes {
    let path = "\(outputDir)/\(filename)"
    if let scaled = scaleImage(baseImage, to: pixelSize) {
        if savePNG(scaled, to: path) {
            print("  Saved \(filename) (\(pixelSize)x\(pixelSize))")
        } else {
            print("  ERROR: Failed to save \(filename)")
            success = false
        }
    } else {
        print("  ERROR: Failed to scale to \(pixelSize)x\(pixelSize)")
        success = false
    }
}

if success {
    print("\nAll icons generated successfully in \(outputDir)/")
} else {
    print("\nSome icons failed to generate")
    exit(1)
}
```

**Step 3: Make the script executable**

Run: `chmod +x scripts/generate-app-icon.swift`

**Step 4: Commit**

```bash
git add scripts/generate-app-icon.swift
git commit -m "feat: add app icon generator script"
```

---

### Task 2: Run the generator and verify output

**Files:**
- Verify: `FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/*.png`

**Step 1: Run the script from the project root**

Run: `swift scripts/generate-app-icon.swift`

Expected output:
```
Generated base 1024x1024 icon
  Saved icon_1024x1024.png (1024x1024)
  Saved icon_512x512@2x.png (1024x1024)
  Saved icon_512x512.png (512x512)
  Saved icon_256x256@2x.png (512x512)
  Saved icon_256x256.png (256x256)
  Saved icon_128x128@2x.png (256x256)
  Saved icon_128x128.png (128x128)
  Saved icon_32x32@2x.png (64x64)
  Saved icon_32x32.png (32x32)
  Saved icon_16x16@2x.png (32x32)
  Saved icon_16x16.png (16x16)

All icons generated successfully in FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/
```

**Step 2: Verify PNGs were created**

Run: `ls -la FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/`

Expected: 11 PNG files plus the existing Contents.json.

**Step 3: Visually verify the 1024x1024 icon**

Run: `open FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024x1024.png`

Verify: Yellow Avian bird centered on sky-blue-to-peach gradient. Bird facing right, tilted up ~10 degrees. Clean geometric shapes.

---

### Task 3: Update Contents.json to reference the generated PNGs

**Files:**
- Modify: `FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`

**Step 1: Update Contents.json with filenames**

Replace the entire contents of `Contents.json` with:

```json
{
  "images" : [
    {
      "filename" : "icon_1024x1024.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "filename" : "icon_16x16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**Step 2: Commit all icon assets**

```bash
git add FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/
git add scripts/generate-app-icon.swift
git commit -m "feat: generate and wire up app icon for iOS and macOS"
```

---

### Task 4: Build verification

**Step 1: Build iOS target**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird-iOS -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`

Expected: `** BUILD SUCCEEDED **`

**Step 2: Build macOS target**

Run: `xcodebuild -project FlappyBird.xcodeproj -scheme FlappyBird-macOS build 2>&1 | tail -5`

Expected: `** BUILD SUCCEEDED **`

---

### Task 5: Iterate on icon appearance (if needed)

If the icon needs visual adjustments after review:

**Tunable parameters in `scripts/generate-app-icon.swift`:**
- `birdScale` — size of bird relative to icon (currently 15.0)
- `cx`, `cy` — bird center position (currently 490, 512)
- `10 * .pi / 180` — tilt angle (currently 10 degrees)
- Gradient colors at top of file
- Any shape coordinates mirror `CharacterRenderer.buildAvian()`

**Iteration loop:**
1. Edit `scripts/generate-app-icon.swift`
2. Run: `swift scripts/generate-app-icon.swift`
3. Run: `open FlappyBird/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024x1024.png`
4. Repeat until satisfied
5. Commit final version
