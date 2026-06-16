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
    // MARK: - Types

    struct LoadedDevice {
        let frame: DeviceFrame
        let frameImage: UIImage
        let screenshotImage: UIImage
    }

    // MARK: - Properties

    let background: Background
    let backgroundImage: UIImage?
    let canvasSize: CGSize
    let devices: [LoadedDevice]
    let headline: Headline

    // MARK: - Computed Properties

    private var canvasScaleX: CGFloat {
        canvasSize.width / OutputSize.largeDimensions.width
    }

    private var canvasScaleY: CGFloat {
        canvasSize.height / OutputSize.largeDimensions.height
    }

    private var deviceFrameBottomY: CGFloat {
        guard let primary = devices.first else { return canvasSize.height / 2 }
        return canvasSize.height / 2 + primary.frame.offset.y * canvasScaleY + frameDisplayHeight(for: primary) / 2
    }

    private var deviceFrameTopY: CGFloat {
        guard let primary = devices.first else { return canvasSize.height / 2 }
        return canvasSize.height / 2 + primary.frame.offset.y * canvasScaleY - frameDisplayHeight(for: primary) / 2
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

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundView

            ForEach(
                devices.indices.dropFirst(),
                id: \.self
            ) { index in
                deviceView(for: devices[index])
                    .offset(
                        x: devices[index].frame.offset.x * canvasScaleX,
                        y: devices[index].frame.offset.y * canvasScaleY
                    )
            }

            if let primary = devices.first {
                switch headline.position {
                case let .above(spacing):
                    VStack(spacing: spacing * canvasScaleY) {
                        headlineView
                        deviceView(for: primary)
                    }
                    .offset(
                        x: primary.frame.offset.x * canvasScaleX,
                        y: primary.frame.offset.y * canvasScaleY
                    )

                case let .below(spacing):
                    VStack(spacing: spacing * canvasScaleY) {
                        deviceView(for: primary)
                        headlineView
                    }
                    .offset(
                        x: primary.frame.offset.x * canvasScaleX,
                        y: primary.frame.offset.y * canvasScaleY
                    )

                case let .canvasBottom(padding):
                    deviceView(for: primary)
                        .offset(
                            x: primary.frame.offset.x * canvasScaleX,
                            y: primary.frame.offset.y * canvasScaleY
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
                    deviceView(for: primary)
                        .offset(
                            x: primary.frame.offset.x * canvasScaleX,
                            y: primary.frame.offset.y * canvasScaleY
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
                    deviceView(for: primary)
                        .offset(
                            x: primary.frame.offset.x * canvasScaleX,
                            y: primary.frame.offset.y * canvasScaleY
                        )

                    headlineView
                        .offset(
                            x: x * canvasScaleX - canvasSize.width / 2,
                            y: y * canvasScaleY - canvasSize.height / 2
                        )

                case let .equidistantBottom(offset):
                    deviceView(for: primary)
                        .offset(
                            x: primary.frame.offset.x * canvasScaleX,
                            y: primary.frame.offset.y * canvasScaleY
                        )

                    headlineView
                        .offset(
                            y: deviceFrameBottomY / 2 + offset * canvasScaleY
                        )

                case let .equidistantTop(offset):
                    deviceView(for: primary)
                        .offset(
                            x: primary.frame.offset.x * canvasScaleX,
                            y: primary.frame.offset.y * canvasScaleY
                        )

                    headlineView
                        .offset(
                            y: deviceFrameTopY / 2 - canvasSize.height / 2 + offset * canvasScaleY
                        )
                }
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

    private func clippedScreenshotImage(
        for device: LoadedDevice,
        size: CGSize,
        cornerRadius: CGFloat
    ) -> UIImage {
        let screenshotImage = device.screenshotImage

        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1

        let imageRenderer = UIGraphicsImageRenderer(
            size: size,
            format: format
        )

        return imageRenderer.image { rendererContext in
            let cgContext = rendererContext.cgContext

            let clipPath = RoundedRectangle(
                cornerRadius: cornerRadius,
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

    private func deviceView(for device: LoadedDevice) -> some View {
        let displayWidth = frameDisplayWidth(for: device)
        let displayHeight = frameDisplayHeight(for: device)
        let pixelWidth = device.frameImage.size.width * device.frameImage.scale
        let scale = displayWidth / pixelWidth
        let screenWidth = displayWidth - (
            device.frame.screenInsets.left + device.frame.screenInsets.right
        ) * scale
        let screenHeight = displayHeight - (
            device.frame.screenInsets.top + device.frame.screenInsets.bottom
        ) * scale
        let cornerRadius = device.frame.screenInsets.cornerRadius * scale
        let screenX = (
            device.frame.screenInsets.left - device.frame.screenInsets.right
        ) * scale / 2
        let screenY = (
            device.frame.screenInsets.top - device.frame.screenInsets.bottom
        ) * scale / 2

        let clippedImage = clippedScreenshotImage(
            for: device,
            size: CGSize(
                width: screenWidth,
                height: screenHeight
            ),
            cornerRadius: cornerRadius
        )

        return ZStack {
            Image(uiImage: clippedImage)
                .frame(
                    width: screenWidth,
                    height: screenHeight
                )
                .offset(
                    x: screenX,
                    y: screenY
                )

            Image(uiImage: device.frameImage)
                .resizable()
                .frame(
                    width: displayWidth,
                    height: displayHeight
                )
        }
        .shadow(
            color: device.frame.shadow?.color ?? .clear,
            radius: (device.frame.shadow?.radius ?? 0) * canvasScaleX,
            x: (device.frame.shadow?.x ?? 0) * canvasScaleX,
            y: (device.frame.shadow?.y ?? 0) * canvasScaleY
        )
    }

    private func frameDisplayHeight(for device: LoadedDevice) -> CGFloat {
        frameDisplayWidth(for: device) * (
            device.frameImage.size.height / device.frameImage.size.width
        )
    }

    private func frameDisplayWidth(for device: LoadedDevice) -> CGFloat {
        canvasSize.width * device.frame.scale
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
