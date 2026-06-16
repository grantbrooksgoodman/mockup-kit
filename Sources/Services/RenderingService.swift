//
//  RenderingService.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

@MainActor
struct RenderingService {
    // MARK: - Methods

    func render(
        _ mockup: Mockup,
        outputSize: OutputSize
    ) throws -> Data {
        let devices: [MockupCanvasView.LoadedDevice] = try mockup.devices.map { entry in
            let frameImage = try loadImage(from: entry.frame.imageFile)

            let screenshotImage = try loadImage(from: entry.screenshotURL)

            return MockupCanvasView.LoadedDevice(
                frame: entry.frame,
                frameImage: frameImage,
                screenshotImage: screenshotImage
            )
        }

        let backgroundImage: UIImage? = if case let .image(url) = mockup.background {
            try loadImage(from: url)
        } else {
            nil
        }

        let canvasView = MockupCanvasView(
            background: mockup.background,
            backgroundImage: backgroundImage,
            canvasSize: outputSize.dimensions,
            devices: devices,
            headline: mockup.headline
        )

        let renderer = ImageRenderer(content: canvasView)
        renderer.scale = 1

        guard let cgImage = renderer.cgImage else {
            throw MockupKit.Error.renderingFailed
        }

        guard let pngData = UIImage(cgImage: cgImage).pngData() else {
            throw MockupKit.Error.encodingFailed
        }

        return pngData
    }

    // MARK: - Auxiliary

    private func loadImage(
        from url: URL
    ) throws -> UIImage {
        guard let image = UIImage(
            contentsOfFile: url.path
        ) else {
            throw MockupKit.Error.imageLoadFailed(url)
        }

        return image
    }
}
