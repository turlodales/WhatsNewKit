import Foundation

/// Backwards-compatible alias for iCloud key-value version storage.
public typealias CloudKitWhatsNewVersionStore = NSUbiquitousKeyValueWhatsNewVersionStore

/// Stores acknowledgement state in iCloud key-value storage.
/// Omit namespace to preserve the existing WhatsNewKit version keys.
public struct NSUbiquitousKeyValueWhatsNewVersionStore {
    private let ubiquitousKeyValueStore: NSUbiquitousKeyValueStore
    private let namespace: String?

    public init(
        ubiquitousKeyValueStore: NSUbiquitousKeyValueStore = .default,
        namespace: String? = nil
    ) {
        self.ubiquitousKeyValueStore = ubiquitousKeyValueStore
        self.namespace = namespace.flatMap { $0.isEmpty ? nil : $0 }
    }

    private var keyPrefix: String {
        if let namespace = namespace {
            return WhatsNew.Version.keyPrefix + "." + namespace + "."
        }
        return WhatsNew.Version.keyPrefix + "."
    }

    private func key(for version: WhatsNew.Version) -> String {
        keyPrefix + version.description
    }

    private var ownedEntries: [(String, WhatsNew.Version)] {
        ubiquitousKeyValueStore.dictionaryRepresentation.compactMap { key, value in
            guard key.hasPrefix(keyPrefix),
                  let value = value as? String,
                  let version = WhatsNew.Version(parsing: value),
                  key == self.key(for: version) else { return nil }
            return (key, version)
        }
    }
}

extension NSUbiquitousKeyValueWhatsNewVersionStore: WriteableWhatsNewVersionStore {
    public func save(presentedVersion version: WhatsNew.Version) {
        ubiquitousKeyValueStore.set(version.description, forKey: key(for: version))
    }
}

extension NSUbiquitousKeyValueWhatsNewVersionStore: ReadableWhatsNewVersionStore {
    public var presentedVersions: [WhatsNew.Version] {
        ownedEntries.map { $0.1 }.sorted()
    }
}

public extension NSUbiquitousKeyValueWhatsNewVersionStore {
    func remove(presentedVersion version: WhatsNew.Version) {
        ubiquitousKeyValueStore.removeObject(forKey: key(for: version))
    }

    func removeAll() {
        ownedEntries.forEach { ubiquitousKeyValueStore.removeObject(forKey: $0.0) }
    }
}
