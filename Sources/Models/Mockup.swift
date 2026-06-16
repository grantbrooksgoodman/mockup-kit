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
/// Each mockup combines a ``Background``, one or more ``DeviceEntry`` values, and a
/// ``Headline`` into a composited image. Pass an array of mockups to
/// ``MockupKit/generate(_:outputSizes:translatingTo:)`` to render them as PNG files.
public struct Mockup: Sendable {
    // MARK: - Properties

    /// The background fill of the mockup canvas.
    public let background: Background

    /// The device entries displayed on the canvas.
    ///
    /// Each entry pairs a ``DeviceFrame`` with an app screenshot. The first
    /// entry in the array is the primary device. Headline positioning for grouped
    /// positions like ``HeadlinePosition/above(spacing:)`` and
    /// ``HeadlinePosition/below(spacing:)`` is calculated relative to the primary
    /// device's frame.
    ///
    /// Use the ``DeviceFrame/offset`` and ``DeviceFrame/scale`` properties on each
    /// entry's frame to position multiple devices side by side.
    public let devices: [DeviceEntry]

    /// The headline text overlaid on the canvas.
    public let headline: Headline

    /// The output filename (without extension) used when writing the mockup to disk.
    public let name: String

    // MARK: - Init

    /// Creates a mockup with the specified background, devices, and headline.
    ///
    /// - Parameters:
    ///   - background: The background fill of the canvas.
    ///   - devices: The device entries to display on the canvas.
    ///   - headline: The headline text to display.
    ///   - name: The output filename without extension.
    public init(
        background: Background,
        devices: [DeviceEntry],
        headline: Headline,
        name: String
    ) {
        self.background = background
        self.devices = devices
        self.headline = headline
        self.name = name
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
            devices: devices,
            headline: Headline(
                text,
                alignment: headline.alignment,
                font: headline.font,
                foregroundColor: headline.foregroundColor,
                maximumWidth: headline.maximumWidth,
                position: headline.position,
                subtitle: newSubtitle
            ),
            name: name
        )
    }
}
