import Foundation
import XCTest
@testable import WhatsNewKit

final class WhatsNewNamespacedStoreTests: XCTestCase {
    private func isolatedDefaults() -> UserDefaults {
        // Test suite is isolated from the application's standard defaults.
        let suiteName = "WhatsNewKit.Tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    func testNamespacesDoNotShareOrDeleteEachOthersVersions() {
        let defaults = isolatedDefaults()
        let freya = UserDefaultsWhatsNewVersionStore(
            userDefaults: defaults, namespace: "Freya"
        )
        let raven = UserDefaultsWhatsNewVersionStore(
            userDefaults: defaults, namespace: "Raven"
        )
        freya.save(presentedVersion: "2027.01")
        raven.save(presentedVersion: "2026.11")

        XCTAssertEqual(freya.presentedVersions, ["2027.01"])
        XCTAssertEqual(raven.presentedVersions, ["2026.11"])
        XCTAssertFalse(freya.hasPresented("2026.11"))

        freya.removeAll()
        XCTAssertTrue(freya.presentedVersions.isEmpty)
        XCTAssertEqual(raven.presentedVersions, ["2026.11"])
    }

    func testLegacyStoreKeepsExistingKeys() {
        let defaults = isolatedDefaults()
        let legacy = UserDefaultsWhatsNewVersionStore(userDefaults: defaults)
        legacy.save(presentedVersion: "1.2.3")
        XCTAssertEqual(defaults.string(forKey: "WhatsNewKit.1.2.3"), "1.2.3")
        XCTAssertEqual(legacy.presentedVersions, ["1.2.3"])
    }

    func testOptInLegacyMigrationCopiesWithoutDeleting() {
        let defaults = isolatedDefaults()
        let legacy = UserDefaultsWhatsNewVersionStore(userDefaults: defaults)
        legacy.save(presentedVersion: "1.2.3")
        let migrated = UserDefaultsWhatsNewVersionStore(
            userDefaults: defaults,
            namespace: "Freya",
            migrateLegacy: true
        )
        XCTAssertTrue(migrated.hasPresented("1.2.3"))
        XCTAssertEqual(defaults.string(forKey: "WhatsNewKit.Freya.1.2.3"), "1.2.3")
        XCTAssertTrue(legacy.hasPresented("1.2.3"))
    }

    func testMalformedAndOtherNamespaceKeysAreIgnored() {
        let defaults = isolatedDefaults()
        defaults.set("1.2.3", forKey: "WhatsNewKit.Other.1.2.3")
        defaults.set("bad.version", forKey: "WhatsNewKit.Freya.bad.version")
        defaults.set("1.2.3", forKey: "WhatsNewKit.Freya.8.8.8")
        let freya = UserDefaultsWhatsNewVersionStore(
            userDefaults: defaults, namespace: "Freya"
        )
        XCTAssertTrue(freya.presentedVersions.isEmpty)
        freya.removeAll()
        XCTAssertNotNil(defaults.object(forKey: "WhatsNewKit.Other.1.2.3"))
    }
    func testDefaultStoreDoesNotReadOrRemoveNamespacedVersions() {
        let defaults = isolatedDefaults()
        let legacy = UserDefaultsWhatsNewVersionStore(userDefaults: defaults)
        let scoped = UserDefaultsWhatsNewVersionStore(
            userDefaults: defaults, namespace: "Freya"
        )
        legacy.save(presentedVersion: "1.0.0")
        scoped.save(presentedVersion: "2.0.0")
        XCTAssertEqual(legacy.presentedVersions, ["1.0.0"])
        legacy.removeAll()
        XCTAssertEqual(scoped.presentedVersions, ["2.0.0"])
    }

    func testMigrationIsOptInAndDoesNotOverwriteExistingNamespace() {
        let defaults = isolatedDefaults()
        let legacy = UserDefaultsWhatsNewVersionStore(userDefaults: defaults)
        legacy.save(presentedVersion: "1.2.3")

        let isolated = UserDefaultsWhatsNewVersionStore(
            userDefaults: defaults, namespace: "Freya"
        )
        XCTAssertTrue(isolated.presentedVersions.isEmpty)

        let migrated = UserDefaultsWhatsNewVersionStore(
            userDefaults: defaults,
            namespace: "Freya",
            migrateLegacy: true
        )
        XCTAssertEqual(migrated.presentedVersions, ["1.2.3"])
        migrated.removeAll()
        XCTAssertTrue(isolated.presentedVersions.isEmpty)
        XCTAssertEqual(legacy.presentedVersions, ["1.2.3"])
    }

}
