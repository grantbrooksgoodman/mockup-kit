//
//  Mockup+Constants.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation
import SwiftUI

// MARK: - MockupCanvasView

extension MockupCanvasView {
    /// The default headline width as a fraction of the canvas width, used when
    /// ``Headline/maximumWidth`` is `nil`.
    static let defaultHeadlineWidthRatio: CGFloat = 0.85
}

// MARK: - MockupShadow

public extension MockupShadow {
    /// A subtle drop shadow that adds depth behind the device frame.
    ///
    /// Uses a soft black shadow offset slightly downward, producing a natural
    /// floating effect on colored backgrounds.
    static let `default` = MockupShadow(
        color: Color.black.opacity(0.15),
        radius: 40,
        x: 0,
        y: 20
    )
}

// MARK: - OutputSize

extension OutputSize {
    /// The canvas dimensions for the 6.9-inch display class (1290 x 2796).
    static let largeDimensions = CGSize(
        width: 1290,
        height: 2796
    )

    /// The canvas dimensions for the 5.5-inch display class (1242 x 2208).
    static let smallDimensions = CGSize(
        width: 1242,
        height: 2208
    )
}
