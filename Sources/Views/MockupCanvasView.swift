//
//  MockupCanvasView.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

/* Proprietary */
import ComponentKit

@MainActor
struct MockupCanvasView: View {
    // MARK: - Properties

    let background: Background
    let backgroundImage: UIImage?
    let canvasSize: CGSize
    let frame: DeviceFrame
    let frameImage: UIImage
    let headline: Headline
    let screenshotImage: UIImage?

    // MARK: - Computed Properties

    private var canvasScaleX: CGFloat {
        canvasSize.width / OutputSize.largeDimensions.width
    }

    private var canvasScaleY: CGFloat {
        canvasSize.height / OutputSize.largeDimensions.height
    }

    private var clippedScreenshotImage: UIImage? {
        guard let screenshotImage else { return nil }
        let size = CGSize(
            width: screenDisplayWidth,
            height: screenDisplayHeight
        )

        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1

        let imageRenderer = UIGraphicsImageRenderer(
            size: size,
            format: format
        )

        return imageRenderer.image { rendererContext in
            let cgContext = rendererContext.cgContext

            // Clip to a continuous rounded rectangle matching the
            // bezel's screen opening.
            let clipPath = RoundedRectangle(
                cornerRadius: screenCornerRadius,
                style: .continuous
            )
            .path(
                in: CGRect(
                    origin: .zero,
                    size: size
                )
            )

            cgContext.addPath(clipPath.cgPath)
            cgContext.clip()

            // Draw screenshot scaled to fill the screen area.
            let imageAspect = screenshotImage.size.width / screenshotImage.size.height
            let rectAspect = size.width / size.height
            let drawRect: CGRect

            if imageAspect > rectAspect {
                let drawWidth = size.height * imageAspect
                drawRect = CGRect(
                    x: (size.width - drawWidth) / 2,
                    y: 0,
                    width: drawWidth,
                    height: size.height
                )
            } else {
                let drawHeight = size.width / imageAspect
                drawRect = CGRect(
                    x: 0,
                    y: (size.height - drawHeight) / 2,
                    width: size.width,
                    height: drawHeight
                )
            }

            screenshotImage.draw(in: drawRect)
        }
    }

    private var deviceFrameBottomY: CGFloat {
        canvasSize.height / 2 + frame.offset.y * canvasScaleY + frameDisplayHeight / 2
    }

    private var deviceFrameTopY: CGFloat {
        canvasSize.height / 2 + frame.offset.y * canvasScaleY - frameDisplayHeight / 2
    }

    private var frameDisplayHeight: CGFloat {
        frameDisplayWidth * (
            frameImage.size.height / frameImage.size.width
        )
    }

    private var frameDisplayWidth: CGFloat {
        canvasSize.width * frame.scale
    }

    private var framePixelWidth: CGFloat {
        frameImage.size.width * frameImage.scale
    }

    private var headlineHorizontalAlignment: HorizontalAlignment {
        switch headline.alignment {
        case .center: .center
        case .leading: .leading
        case .trailing: .trailing
        }
    }

    private var scaledFont: ComponentKit.Font {
        ComponentKit.Font(
            headline.font.type,
            scale: .custom(headline.font.scale.points * canvasScaleY)
        )
    }

    private var scaledSubtitleFont: ComponentKit.Font? {
        guard let subtitle = headline.subtitle else { return nil }
        return ComponentKit.Font(
            subtitle.font.type,
            scale: .custom(subtitle.font.scale.points * canvasScaleY)
        )
    }

    private var scaleFactor: CGFloat {
        frameDisplayWidth / framePixelWidth
    }

    private var screenCornerRadius: CGFloat {
        frame.screenInsets.cornerRadius * scaleFactor
    }

    private var screenDisplayHeight: CGFloat {
        frameDisplayHeight - (
            frame.screenInsets.top + frame.screenInsets.bottom
        ) * scaleFactor
    }

    private var screenDisplayWidth: CGFloat {
        frameDisplayWidth - (
            frame.screenInsets.left + frame.screenInsets.right
        ) * scaleFactor
    }

    private var screenOffsetX: CGFloat {
        (
            frame.screenInsets.left - frame.screenInsets.right
        ) * scaleFactor / 2
    }

    private var screenOffsetY: CGFloat {
        (
            frame.screenInsets.top - frame.screenInsets.bottom
        ) * scaleFactor / 2
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundView

            switch headline.position {
            case let .above(spacing):
                VStack(spacing: spacing * canvasScaleY) {
                    headlineView
                    deviceView
                }
                .offset(
                    x: frame.offset.x * canvasScaleX,
                    y: frame.offset.y * canvasScaleY
                )

            case let .below(spacing):
                VStack(spacing: spacing * canvasScaleY) {
                    deviceView
                    headlineView
                }
                .offset(
                    x: frame.offset.x * canvasScaleX,
                    y: frame.offset.y * canvasScaleY
                )

            case let .canvasBottom(padding):
                deviceView
                    .offset(
                        x: frame.offset.x * canvasScaleX,
                        y: frame.offset.y * canvasScaleY
                    )

                VStack {
                    Spacer()
                    headlineView
                        .padding(
                            .bottom,
                            padding * canvasScaleY
                        )
                }

            case let .canvasTop(padding):
                deviceView
                    .offset(
                        x: frame.offset.x * canvasScaleX,
                        y: frame.offset.y * canvasScaleY
                    )

                VStack {
                    headlineView
                        .padding(
                            .top,
                            padding * canvasScaleY
                        )

                    Spacer()
                }

            case let .custom(x, y):
                deviceView
                    .offset(
                        x: frame.offset.x * canvasScaleX,
                        y: frame.offset.y * canvasScaleY
                    )

                headlineView
                    .offset(
                        x: x * canvasScaleX - canvasSize.width / 2,
                        y: y * canvasScaleY - canvasSize.height / 2
                    )

            case let .equidistantBottom(offset):
                deviceView
                    .offset(
                        x: frame.offset.x * canvasScaleX,
                        y: frame.offset.y * canvasScaleY
                    )

                headlineView
                    .offset(
                        y: deviceFrameBottomY / 2 + offset * canvasScaleY
                    )

            case let .equidistantTop(offset):
                deviceView
                    .offset(
                        x: frame.offset.x * canvasScaleX,
                        y: frame.offset.y * canvasScaleY
                    )

                headlineView
                    .offset(
                        y: deviceFrameTopY / 2 - canvasSize.height / 2 + offset * canvasScaleY
                    )
            }
        }
        .frame(
            width: canvasSize.width,
            height: canvasSize.height
        )
        .clipped()
    }

    // MARK: - Auxiliary

    @ViewBuilder
    private var backgroundView: some View {
        switch background {
        case let .color(color):
            color

        case .image:
            if let backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }

        case let .linearGradient(
            colors,
            startPoint,
            endPoint
        ):
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
        }
    }

    private var deviceView: some View {
        ZStack {
            screenContentView
                .frame(
                    width: screenDisplayWidth,
                    height: screenDisplayHeight
                )
                .offset(
                    x: screenOffsetX,
                    y: screenOffsetY
                )

            Image(uiImage: frameImage)
                .resizable()
                .frame(
                    width: frameDisplayWidth,
                    height: frameDisplayHeight
                )
        }
        .shadow(
            color: frame.shadow?.color ?? .clear,
            radius: (frame.shadow?.radius ?? 0) * canvasScaleX,
            x: (frame.shadow?.x ?? 0) * canvasScaleX,
            y: (frame.shadow?.y ?? 0) * canvasScaleY
        )
    }

    private var headlineView: some View {
        VStack(
            alignment: headlineHorizontalAlignment,
            spacing: (headline.subtitle?.spacing ?? 0) * canvasScaleY
        ) {
            Components.text(
                headline.text.sanitized,
                font: scaledFont,
                foregroundColor: headline.foregroundColor
            )
            .multilineTextAlignment(headline.alignment)

            if let subtitle = headline.subtitle,
                let subtitleFont = scaledSubtitleFont {
                Components.text(
                    subtitle.text.sanitized,
                    font: subtitleFont,
                    foregroundColor: subtitle.foregroundColor
                )
                .multilineTextAlignment(headline.alignment)
            }
        }
        .frame(
            maxWidth: headline.maximumWidth.map {
                $0 * canvasScaleX
            } ?? canvasSize.width * Self.defaultHeadlineWidthRatio
        )
    }

    @ViewBuilder
    private var screenContentView: some View {
        if let clippedScreenshotImage {
            Image(uiImage: clippedScreenshotImage)
        } else {
            Color.black
        }
    }
}

private extension String {
    /// Returns a copy of the string with translation sentinel
    /// characters removed.
    ///
    /// The characters `⌘` (U+2318), `⁂` (U+2042), and `※` (U+203B)
    /// are used as internal delimiters during translation
    /// tokenization. They must be stripped from all user-facing text
    /// before display.
    var sanitized: String {
        replacingOccurrences(of: "⌘", with: "")
            .replacingOccurrences(of: "⁂", with: "")
            .replacingOccurrences(of: "※", with: "")
    }
}
