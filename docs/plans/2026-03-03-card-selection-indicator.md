# Card Selection Indicator Enhancement — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make selected cards visually obvious on both character and environment selection screens.

**Architecture:** Enhance existing card modifiers — stronger glow, visible blue border on selected cards, slight opacity dimming on unselected cards. Same values on both screens for consistency.

**Tech Stack:** SwiftUI (view modifiers, overlay, opacity, shadow)

---

### Task 1: Update CharacterSelectionView card styling

**Files:**
- Modify: `FlappyBird/Views/CharacterSelectionView.swift:118-128`

**Step 1: Update the characterCard function modifiers**

Replace lines 118-128 (the modifiers after the VStack closing brace) with:

```swift
        .frame(width: size, height: size)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue.opacity(0.6) : Color.clear, lineWidth: 2.5)
        )
        .shadow(color: isSelected ? Color.blue.opacity(0.5) : Color.clear, radius: 16)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .opacity(isSelected ? 1.0 : 0.7)
```

Changes from original:
- `.stroke` — `Color.clear, lineWidth: 0` → `isSelected ? Color.blue.opacity(0.6) : Color.clear, lineWidth: 2.5`
- `.shadow` glow — `opacity(0.3), radius: 12` → `opacity(0.5), radius: 16`
- Added `.opacity(isSelected ? 1.0 : 0.7)` for unselected dimming

**Step 2: Build and visually verify**

Run: `Cmd+B` in Xcode or `xcodebuild build -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: Builds with no errors. Character cards show blue border + stronger glow when selected, unselected cards are slightly dimmed.

**Step 3: Commit**

```bash
git add FlappyBird/Views/CharacterSelectionView.swift
git commit -m "feat: enhance character card selection indicator with border, stronger glow, and dimming"
```

---

### Task 2: Update EnvironmentSelectionView card styling

**Files:**
- Modify: `FlappyBird/Views/EnvironmentSelectionView.swift:76-83`

**Step 1: Update the environmentCard function modifiers**

Replace lines 76-83 (the modifiers after the VStack content) with:

```swift
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue.opacity(0.6) : Color.clear, lineWidth: 2.5)
        )
        .shadow(color: isSelected ? Color.blue.opacity(0.5) : Color.clear, radius: 16)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .opacity(isSelected ? 1.0 : 0.7)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
```

Changes from original:
- Added `.overlay` with blue border stroke (matches Task 1)
- `.shadow` glow — `opacity(0.3), radius: 12` → `opacity(0.5), radius: 16`
- Added `.opacity(isSelected ? 1.0 : 0.7)` for unselected dimming

**Step 2: Build and visually verify**

Run: `Cmd+B` in Xcode or `xcodebuild build -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16'`
Expected: Builds with no errors. Environment cards match the same selection styling as character cards.

**Step 3: Commit**

```bash
git add FlappyBird/Views/EnvironmentSelectionView.swift
git commit -m "feat: enhance environment card selection indicator with border, stronger glow, and dimming"
```

---

### Task 3: Final verification

**Step 1: Run full build**

```bash
xcodebuild build -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: Clean build, zero warnings related to these changes.

**Step 2: Manual QA checklist**

- [ ] Character selection (1P): selected card has blue border + glow, unselected are dimmed
- [ ] Character selection (2P): both pickers show correct selection indicators independently
- [ ] Character selection (2P compact/iPhone): same behavior in compact layout
- [ ] Environment selection: tapping a card shows blue border + glow, others dim
- [ ] Animations are smooth on selection change (spring physics)
- [ ] No visual glitches when switching between screens
