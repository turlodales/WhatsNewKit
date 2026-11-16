import XCTest
@testable import WhatsNewKit

// MARK: - WhatsNewEnvironmentTests

/// The WhatsNewEnvironmentTests
final class WhatsNewEnvironmentTests: WhatsNewKitTestCase {
    
    func testInitial() {
        let version_1_0_0: WhatsNew.Version = "1.0.0"
        let whatsNew_1_0_0 = self.makeWhatsNew(from: version_1_0_0)
        let versionStore = InMemoryWhatsNewVersionStore()
        let environment = WhatsNewEnvironment(
            currentVersion: version_1_0_0,
            versionStore: versionStore,
            whatsNewCollection: [whatsNew_1_0_0]
        )
        XCTAssertEqual(
            version_1_0_0,
            environment.whatsNew()?.version
        )
    }
    
    func testInitialReopen() {
        let version_1_0_0: WhatsNew.Version = "1.0.0"
        let whatsNew_1_0_0 = self.makeWhatsNew(from: version_1_0_0)
        let versionStore = InMemoryWhatsNewVersionStore()
        versionStore.save(presentedVersion: version_1_0_0)
        let environment = WhatsNewEnvironment(
            currentVersion: version_1_0_0,
            versionStore: versionStore,
            whatsNewCollection: [whatsNew_1_0_0]
        )
        XCTAssertNil(
            environment.whatsNew()
        )
    }
    
    func testUpdate() {
        let version_1_0_0: WhatsNew.Version = "1.0.0"
        let whatsNew_1_0_0 = self.makeWhatsNew(from: version_1_0_0)
        let version_1_0_1: WhatsNew.Version = "1.0.1"
        let whatsNew_1_0_1 = self.makeWhatsNew(from: version_1_0_1)
        let versionStore = InMemoryWhatsNewVersionStore()
        versionStore.save(presentedVersion: version_1_0_0)
        let environment = WhatsNewEnvironment(
            currentVersion: version_1_0_1,
            versionStore: versionStore,
            whatsNewCollection: [
                whatsNew_1_0_0,
                whatsNew_1_0_1
            ]
            .shuffled()
        )
        XCTAssertEqual(
            version_1_0_1,
            environment.whatsNew()?.version
        )
    }
    
    func testInitialAfterUpdates() {
        let version_1_0_0: WhatsNew.Version = "1.0.0"
        let whatsNew_1_0_0 = self.makeWhatsNew(from: version_1_0_0)
        let version_1_1_0: WhatsNew.Version = "1.1.0"
        let whatsNew_1_1_0 = self.makeWhatsNew(from: version_1_1_0)
        let versionStore = InMemoryWhatsNewVersionStore()
        let environment = WhatsNewEnvironment(
            currentVersion: "1.1.1",
            versionStore: versionStore,
            whatsNewCollection: [
                whatsNew_1_0_0,
                whatsNew_1_1_0
            ]
            .shuffled()
        )
        XCTAssertEqual(
            version_1_1_0,
            environment.whatsNew()?.version
        )
    }
    
    func testInitialAfterUpdatesReopen() {
        let version_1_0_0: WhatsNew.Version = "1.0.0"
        let whatsNew_1_0_0 = self.makeWhatsNew(from: version_1_0_0)
        let version_1_1_0: WhatsNew.Version = "1.1.0"
        let whatsNew_1_1_0 = self.makeWhatsNew(from: version_1_1_0)
        let versionStore = InMemoryWhatsNewVersionStore()
        versionStore.save(presentedVersion: version_1_1_0)
        let environment = WhatsNewEnvironment(
            currentVersion: "1.1.1",
            versionStore: versionStore,
            whatsNewCollection: [
                whatsNew_1_0_0,
                whatsNew_1_1_0
            ]
            .shuffled()
        )
        XCTAssertNil(
            environment.whatsNew()
        )
    }
    
    
    func testSkippedMonthlyUpdatesShowsLatestEligibleRelease() {
        let store = InMemoryWhatsNewVersionStore()
        store.save(presentedVersion: "2026.09")
        let environment = WhatsNewEnvironment(
            currentVersion: "2027.01",
            versionStore: store,
            whatsNewCollection: [
                makeWhatsNew(from: "2027.02"),
                makeWhatsNew(from: "2026.11"),
                makeWhatsNew(from: "2027.01"),
                makeWhatsNew(from: "2026.09")
            ]
        )
        XCTAssertEqual(environment.whatsNew()?.version, "2027.01")
    }

    func testAcknowledgedLatestDoesNotShowOlderRelease() {
        let store = InMemoryWhatsNewVersionStore()
        store.save(presentedVersion: "2027.01")
        let environment = WhatsNewEnvironment(
            currentVersion: "2027.01",
            versionStore: store,
            whatsNewCollection: [
                makeWhatsNew(from: "2026.11"),
                makeWhatsNew(from: "2027.01")
            ]
        )
        XCTAssertNil(environment.whatsNew())
    }

    func testFutureReleasesAreNotDisplayed() {
        let environment = WhatsNewEnvironment(
            currentVersion: "2026.11",
            versionStore: InMemoryWhatsNewVersionStore(),
            whatsNewCollection: [
                makeWhatsNew(from: "2027.01"),
                makeWhatsNew(from: "2026.10")
            ]
        )
        XCTAssertEqual(environment.whatsNew()?.version, "2026.10")
    }

    func testNoEligibleRelease() {
        let environment = WhatsNewEnvironment(
            currentVersion: "2026.11",
            versionStore: InMemoryWhatsNewVersionStore(),
            whatsNewCollection: [
                makeWhatsNew(from: "2027.01")
            ]
        )
        XCTAssertNil(environment.whatsNew())
    }

}
