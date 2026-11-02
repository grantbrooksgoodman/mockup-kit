//
//  BaselineTests.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import Testing

/* Proprietary */
@testable import MockupKit

@MainActor
struct BaselineTests {
    // MARK: - Properties

    private static let baselineDirectory = URL(
        filePath: "/tmp/MockupKitBaseline"
    )

    // MARK: - Methods

    @Test
    func customMatchesBaseline() throws {
        try verifyBaseline(
            for: .custom(
                width: 1080,
                height: 1920
            )
        )
    }

    @Test
    func largeMatchesBaseline() throws {
        try verifyBaseline(for: .large)
    }

    @Test
    func smallMatchesBaseline() throws {
        try verifyBaseline(for: .small)
    }

    // MARK: - Auxiliary

    private func verifyBaseline(for outputSize: OutputSize) throws {
        let mockup = try Fixtures.makeMockup(
            frameURL: Fixtures.writeFrame(),
            screenshotURL: Fixtures.writeScreenshot()
        )

        let data = try MockupKit.render(
            mockup,
            outputSize: outputSize
        )

        let header = try #require(PNGHeader(data: data))
        #expect(header.colorType == 6)
        #expect(header.width == UInt32(outputSize.dimensions.width))
        #expect(header.height == UInt32(outputSize.dimensions.height))

        let baselineURL = Self.baselineDirectory.appending(
            path: outputSize.directoryName.replacingOccurrences(
                of: "/",
                with: "-"
            ) + ".png"
        )

        guard FileManager.default.fileExists(atPath: baselineURL.path) else {
            try FileManager.default.createDirectory(
                at: Self.baselineDirectory,
                withIntermediateDirectories: true
            )

            try data.write(to: baselineURL)
            return print("Recorded baseline: \(baselineURL.path)")
        }

        #expect(try Data(contentsOf: baselineURL) == data)
    }
}
