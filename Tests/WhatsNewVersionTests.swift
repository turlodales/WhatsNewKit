import XCTest
@testable import WhatsNewKit

final class WhatsNewVersionTests: WhatsNewKitTestCase {

    func testStringLiteral() {
        let version = WhatsNew.Version(stringLiteral: "9.9.9")
        XCTAssertEqual("9.9.9", version.description)
    }

    func testBadStringLiteral() {
        let version = WhatsNew.Version(stringLiteral: UUID().uuidString)
        XCTAssertEqual("0.0.0", version.description)
    }

    func testRejectsMalformedVersionWithoutDroppingComponents() {
        XCTAssertNil(WhatsNew.Version(parsing: "1.invalid.2"))
        XCTAssertNil(WhatsNew.Version(parsing: "1..2"))
        XCTAssertNil(WhatsNew.Version(parsing: "1.2.3.4"))
        XCTAssertNil(WhatsNew.Version(parsing: "-1.2.3"))
        XCTAssertNil(WhatsNew.Version(parsing: "1.2beta"))
        XCTAssertNil(WhatsNew.Version(parsing: ""))
        XCTAssertEqual("0.0.0", WhatsNew.Version(stringLiteral: "1.invalid.2").description)
    }

    func testTwoComponentVersion() {
        let version = WhatsNew.Version(parsing: "2027.01")
        XCTAssertEqual(2027, version?.major)
        XCTAssertEqual(1, version?.minor)
        XCTAssertEqual(0, version?.patch)
    }

    func testNumericComparison() {
        XCTAssertTrue(WhatsNew.Version(stringLiteral: "1.9.0") < WhatsNew.Version(stringLiteral: "1.10.0"))
        XCTAssertTrue(WhatsNew.Version(stringLiteral: "2026.12.0") < WhatsNew.Version(stringLiteral: "2027.1.0"))
    }

    func testComparable() {
        let sortedVersions: [WhatsNew.Version] = [
            "1.0.0", "1.0.1", "1.1.1", "1.1.2",
            "1.2.0", "2.0.0", "2.0.1", "2.1.0"
        ]
        XCTAssertEqual(sortedVersions, sortedVersions.shuffled().sorted())
    }

    func testCurrent() {
        class FakeBundle: Bundle {
            let shortVersionString: String
            init(shortVersionString: String) {
                self.shortVersionString = shortVersionString
                super.init()
            }
            override var infoDictionary: [String: Any]? {
                ["CFBundleShortVersionString": shortVersionString]
            }
        }
        let version = self.makeRandomWhatsNewVersion()
        XCTAssertEqual(
            version,
            WhatsNew.Version.current(in: FakeBundle(shortVersionString: version.description))
        )
        XCTAssertEqual(
            WhatsNew.Version(major: 0, minor: 0, patch: 0),
            WhatsNew.Version.current(in: FakeBundle(shortVersionString: ""))
        )
    }

    func testKeyPrefix() {
        XCTAssertEqual("WhatsNewKit", WhatsNew.Version.keyPrefix)
    }

    func testKey() {
        let version = self.makeRandomWhatsNewVersion()
        XCTAssertEqual("WhatsNewKit.\(version.description)", version.key)
    }
}
