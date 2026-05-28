//
//  TranslationDelegateProtocol.swift
//
//  Created by Grant Brooks Goodman.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//

/* Native */
import Foundation

/// An object that translates headline text for multilingual mockup generation.
///
/// Conform your translation service to this protocol and register it using
/// ``MockupKit/Config/registerTranslationDelegate(_:)`` to enable automated headline
/// translation during mockup generation.
///
/// ```swift
/// extension TranslationService: MockupKit.TranslationDelegate {
///     public func translate(_ text: String, to languageCode: String) async throws -> String {
///         let input = TranslationInput(original: text)
///         let pair = LanguagePair(from: "en", to: languageCode)
///         return try await translate(input, languagePair: pair).output
///     }
/// }
/// ```
@MainActor
public protocol TranslationDelegate: Sendable {
    /// Translates the given text into the specified language.
    ///
    /// - Parameters:
    ///   - text: The source text to translate.
    ///   - languageCode: The ISO 639-1 target language code.
    /// - Returns: The translated text.
    func translate(
        _ text: String,
        to languageCode: String
    ) async throws -> String
}
