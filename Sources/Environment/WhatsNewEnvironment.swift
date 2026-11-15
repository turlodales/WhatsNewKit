
import Foundation

// MARK: - WhatsNewEnvironment

/// Manages available releases and determines which
/// What's New announcement should be displayed.
///
/// WhatsNewKit 3.0
open class WhatsNewEnvironment {

    // MARK: - Properties

    /// The current installed application version.
    public let currentVersion: WhatsNew.Version

    /// Stores versions that have already been presented.
    public let whatsNewVersionStore: WhatsNewVersionStore

    /// Default layout for What's New presentations.
    public let defaultLayout: WhatsNew.Layout

    /// All registered What's New releases.
    public let whatsNewCollection: WhatsNewCollection

    // MARK: - Initializers

    public init(
        currentVersion: WhatsNew.Version = .current(),
        versionStore: WhatsNewVersionStore = UserDefaultsWhatsNewVersionStore(),
        defaultLayout: WhatsNew.Layout = .default,
        whatsNewCollection: WhatsNewCollection = .init()
    ) {
        self.currentVersion = currentVersion
        self.whatsNewVersionStore = versionStore
        self.defaultLayout = defaultLayout
        self.whatsNewCollection = whatsNewCollection
    }

    /// Initialize using a collection provider.
    public convenience init(
        currentVersion: WhatsNew.Version = .current(),
        versionStore: WhatsNewVersionStore = UserDefaultsWhatsNewVersionStore(),
        defaultLayout: WhatsNew.Layout = .default,
        whatsNewCollection provider: WhatsNewCollectionProvider
    ) {
        self.init(
            currentVersion: currentVersion,
            versionStore: versionStore,
            defaultLayout: defaultLayout,
            whatsNewCollection: provider.whatsNewCollection
        )
    }

    /// Initialize using a result builder.
    public convenience init(
        currentVersion: WhatsNew.Version = .current(),
        versionStore: WhatsNewVersionStore = UserDefaultsWhatsNewVersionStore(),
        defaultLayout: WhatsNew.Layout = .default,
        @WhatsNewCollectionBuilder
        whatsNewCollection: () -> WhatsNewCollection
    ) {
        self.init(
            currentVersion: currentVersion,
            versionStore: versionStore,
            defaultLayout: defaultLayout,
            whatsNewCollection: whatsNewCollection()
        )
    }

    // MARK: - Available Releases

    /// Releases compatible with the currently installed
    /// app version, sorted newest first.
    open var availableReleases: [WhatsNew] {
        whatsNewCollection
            .filter { $0.version <= currentVersion }
            .sorted { $0.version > $1.version }
    }

    // MARK: - Latest Release

    /// The newest release applicable to this version.
    open var latestRelease: WhatsNew? {
        availableReleases.first
    }

    // MARK: - Presented Versions

    /// Versions that the persistence store has recorded.
    open var presentedVersions: [WhatsNew.Version] {
        whatsNewVersionStore.presentedVersions
    }

    /// Returns true if the specified version
    /// has already been recorded as presented.
    open func hasPresented(
        _ version: WhatsNew.Version
    ) -> Bool {
        whatsNewVersionStore.hasPresented(version)
    }

    // MARK: - Unseen Releases

    /// All applicable releases not yet recorded
    /// as presented, sorted newest first.
    open var unseenReleases: [WhatsNew] {
        availableReleases.filter {
            !hasPresented($0.version)
        }
    }

    /// Number of applicable unseen releases.
    open var unseenReleaseCount: Int {
        unseenReleases.count
    }

    // MARK: - Automatic Presentation

    /// Returns the latest applicable release if it
    /// has not already been presented.
    ///
    /// Older unseen releases remain accessible using
    /// `unseenReleases`, but do not cause repeated
    /// automatic popups after the latest release is seen.
    open func whatsNew() -> WhatsNew? {
        guard let release = latestRelease else {
            return nil
        }

        guard !hasPresented(release.version) else {
            return nil
        }

        return release
    }

    // MARK: - Release Lookup

    /// Find a specific registered release.
    open func release(
        for version: WhatsNew.Version
    ) -> WhatsNew? {
        whatsNewCollection.first {
            $0.version == version
        }
    }

    // MARK: - Release History

    /// All registered releases, including releases
    /// newer than the installed app version.
    open var releaseHistory: [WhatsNew] {
        whatsNewCollection.sorted {
            $0.version > $1.version
        }
    }

    /// The latest release available in the catalogue.
    open var newestRegisteredRelease: WhatsNew? {
        releaseHistory.first
    }

    // MARK: - Version Comparison

    /// Returns true if the specified version
    /// is newer than the installed application.
    open func isFutureVersion(
        _ version: WhatsNew.Version
    ) -> Bool {
        version > currentVersion
    }

    /// Returns true if the specified version
    /// can be displayed by this app version.
    open func isCompatibleVersion(
        _ version: WhatsNew.Version
    ) -> Bool {
        version <= currentVersion
    }
}
