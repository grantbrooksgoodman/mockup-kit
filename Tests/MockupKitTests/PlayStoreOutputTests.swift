//
//  PlayStoreOutputTests.swift
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
struct PlayStoreOutputTests {
    // MARK: - Properties

    private static let appStoreCustomSize = OutputSize.custom(
        width: 1080,
        height: 1920
    )

    private static let playStoreCustomSize = OutputSize.playStore(
        .custom(
            width: 1200,
            height: 2133
        )
    )

    // MARK: - Methods

    @Test
    func appStoreSizesRenderWithAlphaChannel() throws {
        try #expect(renderHeader(for: .large).colorType == 6)
        try #expect(renderHeader(for: .small).colorType == 6)
        try #expect(renderHeader(for: Self.appStoreCustomSize).colorType == 6)
    }

    @Test
    func customRendersWithoutAlphaChannel() throws {
        let header = try renderHeader(for: Self.playStoreCustomSize)
        #expect(header.width == 1200)
        #expect(header.height == 2133)
        #expect(header.colorType == 2)
    }

    @Test
    func directoryNamesIncludePlayStoreSubdirectory() {
        #expect(OutputSize.playStore(.phone).directoryName == "play-store/phone")
        #expect(Self.playStoreCustomSize.directoryName == "play-store/1200x2133")
    }

    @Test
    func generateWritesBeneathPlayStoreSubdirectory() async throws {
        let outputDirectory = makeOutputDirectory()
        let urls = try await MockupKit.generate(
            [makeMockup()],
            outputSizes: [.playStore(.phone)]
        )

        let expectedURL = outputDirectory.appending(
            path: "play-store/phone/fixture.png"
        )

        #expect(urls == [expectedURL])
        #expect(FileManager.default.fileExists(atPath: expectedURL.path))
    }

    @Test
    func generateWritesSourceLanguageWhenTranslating() async throws {
        let outputDirectory = makeOutputDirectory()
        let urls = try await MockupKit.generate(
            [makeMockup()],
            outputSizes: [.playStore(.phone)],
            translatingTo: ["es"]
        )

        let expectedURL = outputDirectory.appending(
            path: "en/play-store/phone/fixture.png"
        )

        #expect(urls == [expectedURL])
        #expect(FileManager.default.fileExists(atPath: expectedURL.path))
    }

    @Test
    func isOpaqueIsTrueOnlyForPlayStoreSizes() {
        #expect(OutputSize.playStore(.phone).isOpaque)
        #expect(Self.playStoreCustomSize.isOpaque)
        #expect(!OutputSize.large.isOpaque)
        #expect(!OutputSize.small.isOpaque)
        #expect(!Self.appStoreCustomSize.isOpaque)
    }

    @Test
    func phoneDimensionsMeetGooglePlayRequirements() {
        let dimensions = OutputSize.playStore(.phone).dimensions
        let longest = max(dimensions.width, dimensions.height)
        let shortest = min(dimensions.width, dimensions.height)

        #expect((320 ... 3840).contains(dimensions.width))
        #expect((320 ... 3840).contains(dimensions.height))
        #expect(longest <= shortest * 2)
    }

    @Test
    func phoneRendersWithoutAlphaChannel() throws {
        let header = try renderHeader(for: .playStore(.phone))
        #expect(header.width == 1080)
        #expect(header.height == 1920)
        #expect(header.bitDepth == 8)
        #expect(header.colorType == 2)
    }

    // MARK: - Auxiliary

    private func makeMockup() throws -> Mockup {
        try Fixtures.makeMockup(
            frameURL: Fixtures.writeFrame(),
            screenshotURL: Fixtures.writeScreenshot()
        )
    }

    private func makeOutputDirectory() -> URL {
        let outputDirectory = Fixtures.directory.appending(
            path: UUID().uuidString
        )

        MockupKit.config.overrideOutputDirectory(outputDirectory)
        return outputDirectory
    }

    private func renderHeader(
        for outputSize: OutputSize
    ) throws -> PNGHeader {
        let data = try MockupKit.render(
            makeMockup(),
            outputSize: outputSize
        )

        return try #require(PNGHeader(data: data))
    }
}
