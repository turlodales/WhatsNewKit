import SwiftUI

/// Optional appearance customisation for What's New screens.
/// Existing layouts remain unchanged unless a theme is explicitly supplied.
public extension WhatsNew {
    struct Theme {
        public enum FeatureStyle {
            case plain
            case cards
        }

        public var backgroundColor: Color
        public var titleColor: Color
        public var featureTitleColor: Color
        public var featureSubtitleColor: Color
        public var cardBackgroundColor: Color
        public var cardCornerRadius: CGFloat
        public var cardPadding: CGFloat
        public var featureStyle: FeatureStyle

        public init(
            backgroundColor: Color = .clear,
            titleColor: Color = .primary,
            featureTitleColor: Color = .primary,
            featureSubtitleColor: Color = .secondary,
            cardBackgroundColor: Color = Color.primary.opacity(0.06),
            cardCornerRadius: CGFloat = 16,
            cardPadding: CGFloat = 16,
            featureStyle: FeatureStyle = .plain
        ) {
            self.backgroundColor = backgroundColor
            self.titleColor = titleColor
            self.featureTitleColor = featureTitleColor
            self.featureSubtitleColor = featureSubtitleColor
            self.cardBackgroundColor = cardBackgroundColor
            self.cardCornerRadius = cardCornerRadius
            self.cardPadding = cardPadding
            self.featureStyle = featureStyle
        }

        public static var classic: Self { .init() }

        public static var cards: Self {
            .init(featureStyle: .cards)
        }
    }
}
