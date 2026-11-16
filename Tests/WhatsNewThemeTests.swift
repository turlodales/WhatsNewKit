import XCTest
@testable import WhatsNewKit

final class WhatsNewThemeTests: XCTestCase {
    func testClassicRemainsDefault() {
        let layout = WhatsNew.Layout()
        XCTAssertEqual(layout.theme.featureStyle, .plain)
        XCTAssertNil(layout.theme.titleColor)
    }

    func testCardsAreOptIn() {
        let layout = WhatsNew.Layout(theme: .cards)
        XCTAssertEqual(layout.theme.featureStyle, .cards)
        XCTAssertGreaterThan(layout.theme.cardCornerRadius, 0)
        XCTAssertGreaterThan(layout.theme.cardPadding, 0)
    }

    func testResetRestoresClassic() {
        var layout = WhatsNew.Layout(theme: .cards)
        layout.reset()
        XCTAssertEqual(layout.theme.featureStyle, .plain)
    }
}
