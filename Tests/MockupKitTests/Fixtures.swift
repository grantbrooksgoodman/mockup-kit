//
//  Fixtures.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import UIKit

/* Proprietary */
import ComponentKit
import MockupKit

@MainActor
enum Fixtures {
    // MARK: - Properties

    static let directory = FileManager.default
        .temporaryDirectory
        .appending(path: UUID().uuidString)

    // MARK: - Methods

    static func makeMockup(
        frameURL: URL,
        screenshotURL: URL
    ) throws -> Mockup {
        try Mockup(
            background: .color(.blue),
            devices: [
                DeviceEntry(
                    frame: DeviceFrame(imageFile: frameURL),
                    screenshotURL: screenshotURL
                ),
            ],
            headline: Headline(
                "Say hello.",
                font: .systemSemibold(scale: .custom(120)),
                foregroundColor: .white
            ),
            name: "fixture"
        )
    }

    static func writeFrame() throws -> URL {
        let bounds = CGRect(
            x: 0,
            y: 0,
            width: 600,
            height: 1200
        )

        let image = makeRenderer(size: bounds.size).image { _ in
            UIColor.black.setFill()
            UIBezierPath(
                roundedRect: bounds,
                cornerRadius: 90
            ).fill()

            UIBezierPath(
                roundedRect: bounds.insetBy(
                    dx: 40,
                    dy: 40
                ),
                cornerRadius: 60
            ).fill(
                with: .clear,
                alpha: 1
            )
        }

        return try write(
            image,
            named: "frame.png"
        )
    }

    static func writeScreenshot() throws -> URL {
        let bounds = CGRect(
            x: 0,
            y: 0,
            width: 520,
            height: 1120
        )

        let image = makeRenderer(size: bounds.size).image { _ in
            UIColor.systemOrange.setFill()
            UIRectFill(bounds)

            UIColor.systemTeal.setFill()
            UIRectFill(
                CGRect(
                    x: 0,
                    y: bounds.midY,
                    width: bounds.width,
                    height: bounds.midY
                )
            )
        }

        return try write(
            image,
            named: "screenshot.png"
        )
    }

    // MARK: - Auxiliary

    private static func makeRenderer(size: CGSize) -> UIGraphicsImageRenderer {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1

        return UIGraphicsImageRenderer(
            size: size,
            format: format
        )
    }

    private static func write(
        _ image: UIImage,
        named name: String
    ) throws -> URL {
        guard let data = image.pngData() else {
            throw MockupKit.Error.encodingFailed
        }

        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let url = directory.appending(path: name)
        try data.write(to: url)
        return url
    }
}

struct PNGHeader {
    // MARK: - Properties

    let bitDepth: UInt8
    let colorType: UInt8
    let height: UInt32
    let width: UInt32

    // MARK: - Init

    init?(data: Data) {
        guard data.count > 25 else { return nil }
        bitDepth = data[24]
        colorType = data[25]
        height = PNGHeader.bigEndianValue(
            in: data,
            at: 20
        )

        width = PNGHeader.bigEndianValue(
            in: data,
            at: 16
        )
    }

    // MARK: - Auxiliary

    private static func bigEndianValue(
        in data: Data,
        at offset: Int
    ) -> UInt32 {
        data[offset ..< offset + 4].reduce(0) { $0 << 8 | UInt32($1) }
    }
}
