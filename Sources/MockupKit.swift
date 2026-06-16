//
//  MockupKit.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

/// A framework for generating App Store screenshot mockups.
///
/// MockupKit composites app screenshots inside device frames with customizable backgrounds
/// and headlines, producing publication-ready PNG images at standard App Store dimensions.
/// Each mockup supports one or more ``DeviceEntry`` values for multi-device compositions.
///
/// Call ``generate(_:outputSizes:translatingTo:)`` to render a batch of mockups to disk,
/// or ``render(_:outputSize:)`` to obtain the image data directly.
@MainActor
public enum MockupKit {
    // MARK: - Properties

    /// The shared configuration for MockupKit.
    public static let config = Config.shared

    // MARK: - Methods

    /// Generates mockup images for the specified output sizes, writing them as PNG files
    /// to the configured output directory.
    ///
    /// When `languageCodes` is non-empty, each mockup's headline is translated and rendered
    /// for every target language. Source-language mockups are placed in a subdirectory named
    /// after ``Config/sourceLanguageCode``.
    ///
    /// - Parameters:
    ///   - mockups: The mockup configurations to render.
    ///   - outputSizes: The output dimensions to generate for each mockup.
    ///   - languageCodes: ISO 639-1 language codes to translate headlines into.
    ///
    /// - Returns: The file URLs of every generated PNG.
    @discardableResult
    public static func generate(
        _ mockups: [Mockup],
        outputSizes: Set<OutputSize>,
        translatingTo languageCodes: [String] = []
    ) async throws -> Set<URL> {
        var generatedFiles = Set<URL>()
        let outputDirectory = config.outputDirectory
        let renderer = RenderingService()

        for mockup in mockups {
            for outputSize in outputSizes {
                let directory: URL = if languageCodes.isEmpty {
                    outputDirectory.appending(path: outputSize.directoryName)
                } else {
                    outputDirectory
                        .appending(path: config.sourceLanguageCode)
                        .appending(path: outputSize.directoryName)
                }

                try FileManager.default.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true
                )

                let fileURL = directory.appending(path: "\(mockup.name).png")
                try renderer.render(
                    mockup,
                    outputSize: outputSize
                ).write(to: fileURL)

                generatedFiles.insert(fileURL)
            }
        }

        guard let delegate = config.translationDelegate,
              !languageCodes.isEmpty else { return generatedFiles }

        for languageCode in languageCodes {
            for mockup in mockups {
                let translatedText = try await delegate.translate(
                    mockup.headline.text,
                    to: languageCode
                )

                let translatedSubtitleText: String? = if let subtitleText = mockup.headline.subtitle?.text {
                    try await delegate.translate(
                        subtitleText,
                        to: languageCode
                    )
                } else {
                    nil
                }

                let translatedMockup = mockup.replacingHeadlineText(
                    with: translatedText,
                    subtitleText: translatedSubtitleText
                )

                for outputSize in outputSizes {
                    let directory = outputDirectory
                        .appending(path: languageCode)
                        .appending(path: outputSize.directoryName)

                    try FileManager.default.createDirectory(
                        at: directory,
                        withIntermediateDirectories: true
                    )

                    let fileURL = directory.appending(path: "\(translatedMockup.name).png")
                    try renderer.render(
                        translatedMockup,
                        outputSize: outputSize
                    ).write(to: fileURL)

                    generatedFiles.insert(fileURL)
                }
            }
        }

        return generatedFiles
    }

    /// Renders a single mockup at the specified output size and returns the PNG data.
    ///
    /// Use this method when you need direct access to the rendered image data without
    /// writing to disk.
    ///
    /// - Parameters:
    ///   - mockup: The mockup configuration to render.
    ///   - outputSize: The output dimensions.
    ///
    /// - Returns: The rendered image as PNG data.
    public static func render(
        _ mockup: Mockup,
        outputSize: OutputSize
    ) throws -> Data {
        try RenderingService().render(
            mockup,
            outputSize: outputSize
        )
    }
}

public extension MockupKit {
    /// The global configuration for the rendering and translation pipeline.
    ///
    /// Access the shared instance through ``MockupKit/config`` to customize the output
    /// directory, source language code, or translation delegate before generating mockups.
    @MainActor
    final class Config {
        // MARK: - Properties

        /// The directory where generated mockup PNGs are written.
        ///
        /// Defaults to `Documents/MockupKit/` within the app's container.
        public private(set) var outputDirectory: URL

        /// The ISO 639-1 language code of the source headline text.
        ///
        /// Used to label the source-language output directory when translating.
        /// Defaults to `"en"`.
        public private(set) var sourceLanguageCode: String

        /// An object that translates headline text into target languages.
        ///
        /// When `nil`, calls to ``MockupKit/generate(_:outputSizes:translatingTo:)``
        /// with non-empty language codes skip translation and generate only the source language.
        public private(set) var translationDelegate: (any TranslationDelegate)?

        fileprivate static let shared = Config()

        // MARK: - Init

        private init() {
            outputDirectory = URL.documentsDirectory.appending(path: "MockupKit")
            sourceLanguageCode = "en"
        }

        // MARK: - Delegate Registration

        /// Registers an object to handle headline translation during mockup generation.
        ///
        /// - Parameter translationDelegate: The object that translates headline text.
        public func registerTranslationDelegate(
            _ translationDelegate: TranslationDelegate
        ) {
            self.translationDelegate = translationDelegate
        }

        // MARK: - Value Overrides

        /// Sets the directory where generated mockup PNGs are written.
        ///
        /// - Parameter outputDirectory: The file URL of the output directory.
        public func overrideOutputDirectory(
            _ outputDirectory: URL
        ) {
            self.outputDirectory = outputDirectory
        }

        /// Sets the language code used to label source-language output.
        ///
        /// - Parameter sourceLanguageCode: An ISO 639-1 language code.
        public func overrideSourceLanguageCode(
            _ sourceLanguageCode: String
        ) {
            self.sourceLanguageCode = sourceLanguageCode
        }
    }
}

public extension MockupKit {
    /// Errors that can occur during mockup rendering or file output.
    enum Error: LocalizedError {
        /// The rendered image could not be encoded as a PNG.
        case encodingFailed

        /// The image at the specified URL could not be loaded.
        case imageLoadFailed(URL)

        /// The image renderer failed to produce a bitmap.
        case renderingFailed

        /// The screen region could not be detected in the device frame image.
        case screenDetectionFailed

        /// Headline translation failed for the given reason.
        case translationFailed(String)

        // MARK: - Computed Properties

        public var errorDescription: String? {
            switch self {
            case .encodingFailed:
                "Failed to encode the rendered image as PNG."

            case let .imageLoadFailed(url):
                "Failed to load image at \(url.path)."

            case .renderingFailed:
                "Failed to render the mockup canvas."

            case .screenDetectionFailed:
                "Failed to detect the screen region in the device frame image."

            case let .translationFailed(reason):
                "Translation failed: \(reason)"
            }
        }
    }
}
