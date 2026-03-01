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
    let birdScale: CGFloat = 15.0
    let cx: CGFloat = 490   // slightly left of center (beak extends right)
    let cy: CGFloat = 512   // vertical center

    ctx.saveGState()
    ctx.translateBy(x: cx, y: cy)
    ctx.scaleBy(x: birdScale, y: birdScale)
    ctx.rotate(by: 10 * .pi / 180)  // 10 degree upward tilt

    // -- Drop shadow --
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
    ctx.rotate(by: 0.2)
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
