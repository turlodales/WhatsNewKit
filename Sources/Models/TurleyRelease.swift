import Foundation
import SwiftUI

/// A monthly release announcement. For example, 2026.11 and 2027.01.
public struct TurleyRelease: Identifiable, Equatable {
    public struct Highlight: Identifiable, Equatable {
        public let title: String
        public let detail: String
        public let symbol: String

        public var id: String { "\(symbol)|\(title)" }

        public init(title: String, detail: String, symbol: String = "star.fill") {
            self.title = title
            self.detail = detail
            self.symbol = symbol
        }
    }

    /// Stable identifier, independent of an app's build number.
    public let id: String
    public let title: String
    public let highlights: [Highlight]

    public init(version: String, title: String, highlights: [Highlight]) {
        self.id = version
        self.title = title
        self.highlights = highlights
    }

    /// Converts a release to the original WhatsNewKit presentation model.
    /// Uses a three-part version to support year.month versions.
    public var whatsNew: WhatsNew {
        let pieces = id.split(separator: ".").compactMap { Int($0) }
        let version = WhatsNew.Version(
            major: pieces.indices.contains(0) ? pieces[0] : 0,
            minor: pieces.indices.contains(1) ? pieces[1] : 0,
            patch: pieces.indices.contains(2) ? pieces[2] : 0
        )
        return WhatsNew(
            version: version,
            title: .init(title),
            features: highlights.map { highlight in
                WhatsNew.Feature(
                    image: .init(systemName: highlight.symbol),
                    title: Text(highlight.title),
                    subtitle: Text(highlight.detail)
                )
            }
        )
    }
}

/// A catalogue that can power an in-app release history, manual announcements,
/// and the existing WhatsNewKit automatic presentation system.
public struct TurleyReleaseCatalog {
    public let releases: [TurleyRelease]

    public init(_ releases: [TurleyRelease]) {
        self.releases = releases
    }

    public var newestFirst: [TurleyRelease] {
        releases.sorted { Self.versionParts($0.id).lexicographicallyPrecedes(Self.versionParts($1.id)) == false && $0.id != $1.id }
    }

    public func release(for version: String) -> TurleyRelease? {
        releases.first { $0.id == version }
    }

    public func latest(upTo version: String) -> TurleyRelease? {
        let target = Self.versionParts(version)
        return newestFirst.first { !target.lexicographicallyPrecedes(Self.versionParts($0.id)) }
    }

    private static func versionParts(_ version: String) -> [Int] {
        let values = version.split(separator: ".").map { Int($0) ?? 0 }
        return values + Array(repeating: 0, count: max(0, 3 - values.count))
    }
}

/// Separate per-app display history, useful when a package is shared by apps.
public struct TurleyReleaseHistory {
    private let defaults: UserDefaults
    private let key: String

    public init(appIdentifier: String, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.key = "TurleyWhatsNewKit.seen.\(appIdentifier)"
    }

    public func hasSeen(_ version: String) -> Bool {
        (defaults.stringArray(forKey: key) ?? []).contains(version)
    }

    public func markSeen(_ version: String) {
        var versions = Set(defaults.stringArray(forKey: key) ?? [])
        versions.insert(version)
        defaults.set(versions.sorted(), forKey: key)
    }

    public func reset() {
        defaults.removeObject(forKey: key)
    }
}
