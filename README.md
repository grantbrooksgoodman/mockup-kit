# MockupKit

A framework for generating publication-ready App Store screenshot mockups with customizable device frames, backgrounds, and localized headlines.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Defining Mockups](#defining-mockups)
  - [Background](#background)
  - [Device Entry](#device-entry)
  - [Device Frame](#device-frame)
  - [Screen Insets](#screen-insets)
  - [Headline](#headline)
  - [Headline Position](#headline-position)
  - [Shadow](#shadow)
- [Output Sizes](#output-sizes)
- [Rendering](#rendering)
- [Configuration](#configuration)
- [Translation](#translation)
- [Error Handling](#error-handling)
- [Dependencies](#dependencies)

---

## Overview

MockupKit composites app screenshots inside device frames with customizable backgrounds and headlines, producing PNG images at standard App Store dimensions. Each mockup supports one or more devices for single- and multi-device compositions.

The framework provides two rendering paths:

- **Batch generation** renders mockup PNGs across multiple output sizes and languages, writing them to a configurable output directory.
- **Direct rendering** returns image data in memory for a single mockup.

MockupKit automatically detects the screen region within a device frame image by scanning its alpha channel, eliminating the need to manually specify screen boundaries for supported frame assets.

---

## Requirements

| Platform | Minimum Version |
| --- | --- |
| iOS | 18.0 |

---

## Installation

MockupKit is distributed as a Swift package. Add it to your project using [Swift Package Manager](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/).

---

## Getting Started

Create a device frame, headline, and mockup, then generate output images:

```swift
import MockupKit

let frame = try DeviceFrame(imageFile: frameURL)

let headline = Headline(
    "Say hello.",
    font: .systemSemibold(scale: .custom(120)),
    foregroundColor: .white
)

let mockup = Mockup(
    background: .color(.blue),
    devices: [
        DeviceEntry(
            frame: frame,
            screenshotURL: screenshotURL
        ),
    ],
    headline: headline,
    name: "screen1"
)

try await MockupKit.generate(
    [mockup],
    outputSizes: [.large, .small]
)
```

Generated PNGs are written to the configured output directory, organized by output size.

---

## Defining Mockups

A [`Mockup`](Sources/Models/Mockup.swift) combines a background, one or more [`DeviceEntry`](Sources/Models/DeviceEntry.swift) values, and a headline into a composited image. Each mockup is identified by a `name` that serves as its output filename.

### Background

[`Background`](Sources/Models/Background.swift) defines the background fill for the mockup canvas. Three options are available:

```swift
// Solid color
.color(.blue)

// Image
.image(imageURL)

// Linear gradient
.linearGradient(
    colors: [.blue, .purple],
    startPoint: .top,
    endPoint: .bottom
)
```

### Device Entry

[`DeviceEntry`](Sources/Models/DeviceEntry.swift) pairs a [`DeviceFrame`](Sources/Models/DeviceFrame.swift) with an app screenshot. Pass one or more entries in the `devices` array to compose single- or multi-device mockups:

```swift
// Single device
let mockup = Mockup(
    background: .color(.blue),
    devices: [
        DeviceEntry(
            frame: frame,
            screenshotURL: screenshotURL
        ),
    ],
    headline: headline,
    name: "screen1"
)

// Two devices side by side
let mockup = Mockup(
    background: .color(.blue),
    devices: [
        DeviceEntry(
            frame: leftFrame,
            screenshotURL: leftScreenshotURL
        ),
        DeviceEntry(
            frame: rightFrame,
            screenshotURL: rightScreenshotURL
        ),
    ],
    headline: headline,
    name: "screen1"
)
```

The first entry in the array is the primary device. Headline positioning is calculated relative to the primary device's frame.

### Device Frame

[`DeviceFrame`](Sources/Models/DeviceFrame.swift) defines the device frame displayed on the mockup canvas. The frame is rendered from a PNG image – typically sourced from [frameit-frames](https://github.com/fastlane/frameit-frames) – with a transparent center where the app screenshot is composited.

```swift
// Automatic screen inset detection
let frame = try DeviceFrame(imageFile: frameURL)

// Custom positioning and scale
let frame = try DeviceFrame(
    imageFile: frameURL,
    offset: CGPoint(x: 0, y: 530),
    scale: 0.89
)
```

The `scale` property sets the frame width as a fraction of the canvas width. The default value is `0.75`.

The `offset` property shifts the frame from the canvas center, in points. Positive `x` moves rightward; positive `y` moves downward. Use this for cropped or off-center compositions.

> **Important:** The frame image must have a fully transparent center where the screen area is. The throwing initializer scans the alpha channel to detect the screen boundaries automatically. If the center pixel is not transparent, initialization fails with `screenDetectionFailed`.

### Screen Insets

[`ScreenInsets`](Sources/Models/ScreenInsets.swift) defines the screen region within a device frame image. Values are specified in the frame image's native pixel coordinate space.

In most cases, you do not need to create screen insets directly – the throwing [`DeviceFrame`](Sources/Models/DeviceFrame.swift) initializer detects them automatically. For cases where manual control is needed, use the explicit initializer:

```swift
let frame = DeviceFrame(
    imageFile: frameURL,
    screenInsets: ScreenInsets(
        bottom: 66,
        cornerRadius: 75,
        left: 75,
        right: 75,
        top: 66
    )
)
```

The `cornerRadius` value determines the continuous rounded rectangle used to clip the screenshot to the bezel's screen opening. A value of `0` disables corner clipping.

### Headline

[`Headline`](Sources/Models/Headline.swift) defines the text overlaid on the mockup canvas. Headlines are rendered using [ComponentKit](https://github.com/grantbrooksgoodman/component-kit) typography.

```swift
let headline = Headline(
    "Chat with anyone.",
    alignment: .leading,
    font: .systemSemibold(scale: .custom(120)),
    foregroundColor: .white,
    position: .equidistantTop(),
    subtitle: .init(
        "Get started today",
        font: .system(scale: .custom(55)),
        foregroundColor: .gray
    )
)
```

Use `\n` for explicit line breaks. Set `maximumWidth` to constrain the text block width in points; when `nil`, the headline uses a default width proportional to the canvas.

A [`Headline.Subtitle`](Sources/Models/Headline.swift) can be attached to display secondary text beneath the headline with its own font, color, and spacing.

### Headline Position

[`HeadlinePosition`](Sources/Models/HeadlinePosition.swift) determines where the headline is placed on the canvas:

| Case | Behavior |
| --- | --- |
| `.above(spacing:)` | Above the primary device frame, moving with its offset. |
| `.below(spacing:)` | Below the primary device frame, moving with its offset. |
| `.canvasTop(padding:)` | Anchored to the top edge of the canvas. |
| `.canvasBottom(padding:)` | Anchored to the bottom edge of the canvas. |
| `.equidistantTop(offset:)` | Centered between the canvas top and the primary device frame top. |
| `.equidistantBottom(offset:)` | Centered between the primary device frame bottom and the canvas bottom. |
| `.custom(x:y:)` | Positioned at an absolute point on the canvas. |

Grouped positions (`.above`, `.below`) move with the primary device frame's offset. Canvas-anchored and equidistant positions are independent of the frame offset.

### Shadow

[`MockupShadow`](Sources/Models/MockupShadow.swift) defines the drop shadow rendered behind the device frame. A default shadow is rendered automatically unless overridden:

```swift
// Custom shadow
let frame = try DeviceFrame(
    imageFile: frameURL,
    shadow: MockupShadow(
        color: .black.opacity(0.2),
        radius: 30,
        x: 0,
        y: 15
    )
)

// No shadow
let frame = try DeviceFrame(
    imageFile: frameURL,
    shadow: nil
)
```

---

## Output Sizes

[`OutputSize`](Sources/Models/OutputSize.swift) defines the output dimensions for a generated mockup PNG. Two preset sizes correspond to standard App Store display classes:

| Case | Dimensions | Display Class |
| --- | --- | --- |
| `.large` | 1290 x 2796 | 6.9-inch |
| `.small` | 1242 x 2208 | 5.5-inch |

Use `.custom(width:height:)` for arbitrary dimensions.

---

## Rendering

[`MockupKit`](Sources/MockupKit.swift) provides two rendering methods:

**Batch generation** renders multiple mockups across output sizes and writes them as PNG files:

```swift
let urls = try await MockupKit.generate(
    [mockup1, mockup2, mockup3],
    outputSizes: [.large, .small]
)
```

**Direct rendering** returns PNG data for a single mockup without writing to disk:

```swift
let pngData = try MockupKit.render(
    mockup,
    outputSize: .large
)
```

---

## Configuration

Access [`MockupKit.Config`](Sources/MockupKit.swift) through `MockupKit.config` to customize rendering behavior before generating mockups:

```swift
// Set the output directory
MockupKit.config.overrideOutputDirectory(customURL)

// Set the source language code (default: "en")
MockupKit.config.overrideSourceLanguageCode("en")

// Register a translation delegate
MockupKit.config.registerTranslationDelegate(myTranslationService)
```

The output directory defaults to `Documents/MockupKit/` within the app's container.

---

## Translation

MockupKit supports automated headline translation through the [`TranslationDelegate`](Sources/Protocols/TranslationDelegateProtocol.swift) protocol. Conform your translation service and register it with the configuration:

```swift
extension MyTranslationService: MockupKit.TranslationDelegate {
    func translate(
        _ text: String,
        to languageCode: String
    ) async throws -> String {
        // Your translation implementation
    }
}

MockupKit.config.registerTranslationDelegate(myTranslationService)
```

Then pass target language codes when generating:

```swift
try await MockupKit.generate(
    mockups,
    outputSizes: [.large, .small],
    translatingTo: ["es", "fr", "de", "ja"]
)
```

Generated files are organized into subdirectories by language code and output size. Source-language mockups use the configured `sourceLanguageCode` as their directory name.

---

## Error Handling

[`MockupKit.Error`](Sources/MockupKit.swift) covers failures across the rendering pipeline:

| Case | Description |
| --- | --- |
| `encodingFailed` | The rendered image could not be encoded as PNG. |
| `imageLoadFailed(URL)` | The image at the specified URL could not be loaded. |
| `renderingFailed` | The image renderer failed to produce a bitmap. |
| `screenDetectionFailed` | The screen region could not be detected in the device frame image. |
| `translationFailed(String)` | Headline translation failed for the given reason. |

---

## Dependencies

MockupKit builds on one companion package:

| Package | Purpose |
| --- | --- |
| [ComponentKit](https://github.com/grantbrooksgoodman/component-kit) | Reusable SwiftUI component primitives and typography. |

---

&copy; NEOTechnica Corporation. All rights reserved.
