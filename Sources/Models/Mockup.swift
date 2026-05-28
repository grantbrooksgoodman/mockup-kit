//
//  Mockup.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

/// A complete configuration for a single App Store screenshot mockup.
///
/// Each mockup combines a ``Background``, ``DeviceFrame``, ``Headline``, and optional app
/// screenshot into a composited image. Pass an array of mockups to
/// ``MockupKit/generate(_:outputSizes:translatingTo:)`` to render them as PNG files.
public struct Mockup: Sendable {
    // MARK: - Properties

    /// The background fill of the mockup canvas.
    public let background: Background

    /// The device frame configuration.
    public let frame: DeviceFrame

    /// The headline text overlaid on the canvas.
    public let headline: Headline

    /// The output filename (without extension) used when writing the mockup to disk.
    public let name: String

    /// The file URL of the app screenshot displayed within the device frame.
    ///
    /// Pass `nil` to render the device frame with a black screen.
    public let screenshotFile: URL?

    // MARK: - Init

    /// Creates a mockup with the specified background, device frame, headline, and screenshot.
    ///
    /// - Parameters:
    ///   - background: The background fill of the canvas.
    ///   - frame: The device frame configuration.
    ///   - headline: The headline text to display.
    ///   - name: The output filename without extension.
    ///   - screenshotFile: The file URL of the app screenshot, or `nil` for a black screen.
    public init(
        background: Background,
        frame: DeviceFrame,
        headline: Headline,
        name: String,
        screenshotFile: URL?
    ) {
        self.background = background
        self.frame = frame
        self.headline = headline
        self.name = name
        self.screenshotFile = screenshotFile
    }

    // MARK: - Methods

    /// Returns a copy of this mockup with the headline text replaced.
    func replacingHeadlineText(
        with text: String,
        subtitleText: String? = nil
    ) -> Mockup {
        let newSubtitle: Headline.Subtitle? = if let subtitleText, let existing = headline.subtitle {
            Headline.Subtitle(
                subtitleText,
                font: existing.font,
                foregroundColor: existing.foregroundColor,
                spacing: existing.spacing
            )
        } else {
            headline.subtitle
        }

        return Mockup(
            background: background,
            frame: frame,
            headline: Headline(
                text,
                alignment: headline.alignment,
                font: headline.font,
                foregroundColor: headline.foregroundColor,
                maximumWidth: headline.maximumWidth,
                position: headline.position,
                subtitle: newSubtitle
            ),
            name: name,
            screenshotFile: screenshotFile
        )
    }
}
