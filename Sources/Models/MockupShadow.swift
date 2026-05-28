//
//  MockupShadow.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

/// A shadow effect rendered behind the device frame.
public struct MockupShadow: Sendable {
    // MARK: - Properties

    /// The shadow color.
    public let color: Color

    /// The blur radius of the shadow.
    public let radius: CGFloat

    /// The horizontal offset of the shadow.
    public let x: CGFloat

    /// The vertical offset of the shadow.
    public let y: CGFloat

    // MARK: - Init

    /// Creates a shadow with the specified color, blur radius, and offset.
    ///
    /// - Parameters:
    ///   - color: The shadow color.
    ///   - radius: The blur radius of the shadow.
    ///   - x: The horizontal offset of the shadow.
    ///   - y: The vertical offset of the shadow.
    public init(
        color: Color,
        radius: CGFloat,
        x: CGFloat,
        y: CGFloat
    ) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}
