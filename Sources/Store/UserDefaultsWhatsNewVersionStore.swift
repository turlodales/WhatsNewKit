import Foundation

/// Persists acknowledged releases in UserDefaults.
///
/// By default, existing legacy keys (WhatsNewKit.1.0.0) are preserved.
/// Set a namespace to isolate independent release catalogues within one
/// UserDefaults suite. Legacy acknowledgement migration is opt-in.
public struct UserDefaultsWhatsNewVersionStore {
    private let userDefaults: UserDefaults
    private let namespace: String?
    private let migrateLegacy: Bool

    public init(
        userDefaults: UserDefaults = .standard,
        namespace: String? = nil,
        migrateLegacy: Bool = false
    ) {
        self.userDefaults = userDefaults
        self.namespace = namespace.flatMap { $0.isEmpty ? nil : $0 }
        self.migrateLegacy = migrateLegacy
    }

    private var keyPrefix: String {
        guard let namespace = namespace else {
            return WhatsNew.Version.keyPrefix + "."
        }
        return WhatsNew.Version.keyPrefix + "." + namespace + "."
    }

    private func key(for version: WhatsNew.Version) -> String {
        keyPrefix + version.description
    }

    private func versions(in dictionary: [String: Any], prefix: String) -> [WhatsNew.Version] {
        dictionary.compactMap { key, value in
            guard key.hasPrefix(prefix),
                  let storedVersion = value as? String,
                  let version = WhatsNew.Version(parsing: storedVersion),
                  key == prefix + version.description else {
                return nil
            }
            return version
        }
    }

    private func migrateIfNeeded() {
        guard migrateLegacy, namespace != nil else { return }

        // Copy only well-formed legacy version entries. Do not remove them:
        // existing consumers must keep their acknowledgement history.
        let dictionary = userDefaults.dictionaryRepresentation()
        let legacyPrefix = WhatsNew.Version.keyPrefix + "."
        for version in versions(in: dictionary, prefix: legacyPrefix) {
            let destination = key(for: version)
            if userDefaults.object(forKey: destination) == nil {
                userDefaults.set(version.description, forKey: destination)
            }
        }
    }
}

extension UserDefaultsWhatsNewVersionStore: WriteableWhatsNewVersionStore {
    public func save(presentedVersion version: WhatsNew.Version) {
        migrateIfNeeded()
        userDefaults.set(version.description, forKey: key(for: version))
    }
}

extension UserDefaultsWhatsNewVersionStore: ReadableWhatsNewVersionStore {
    public var presentedVersions: [WhatsNew.Version] {
        migrateIfNeeded()
        return versions(in: userDefaults.dictionaryRepresentation(), prefix: keyPrefix)
            .sorted()
    }
}

public extension UserDefaultsWhatsNewVersionStore {
    func remove(presentedVersion version: WhatsNew.Version) {
        userDefaults.removeObject(forKey: key(for: version))
    }

    /// Removes only versions belonging to this store's namespace.
    func removeAll() {
        let dictionary = userDefaults.dictionaryRepresentation()
        for key in dictionary.keys where key.hasPrefix(keyPrefix) {
            let suffix = String(key.dropFirst(keyPrefix.count))
            guard let version = WhatsNew.Version(parsing: suffix),
                  key == key(for: version) else { continue }
            userDefaults.removeObject(forKey: key)
        }
    }
}
