//
//  DeviceEntry.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

/// A device frame paired with an app screenshot.
///
/// Each device entry represents a single device on the mockup canvas. Use the
/// ``DeviceFrame/offset`` and ``DeviceFrame/scale`` properties on the entry's frame
/// to control its position and size.
///
/// The first entry in a mockup's ``Mockup/devices`` array is the primary device.
/// Headline positioning is calculated relative to the primary device's frame.
public struct DeviceEntry: Sendable {
    // MARK: - Properties

    /// The device frame configuration.
    public let frame: DeviceFrame

    /// The file URL of the app screenshot displayed within the device frame.
    public let screenshotURL: URL

    // MARK: - Init

    /// Creates a device entry with the specified frame and screenshot.
    ///
    /// - Parameters:
    ///   - frame: The device frame configuration.
    ///   - screenshotURL: The file URL of the app screenshot.
    public init(
        frame: DeviceFrame,
        screenshotURL: URL
    ) {
        self.frame = frame
        self.screenshotURL = screenshotURL
    }
}
