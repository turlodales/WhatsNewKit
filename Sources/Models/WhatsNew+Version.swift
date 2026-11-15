import Foundation

// MARK: - WhatsNew+Version

public extension WhatsNew {

    /// A numeric app version, including year.month versions such as 2027.01.
    struct Version: Hashable {

        public var major: Int
        public var minor: Int
        public var patch: Int

        public init(major: Int, minor: Int, patch: Int) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        /// Strict parser for two- or three-component numeric versions.
        /// Invalid versions return nil instead of silently dropping components.
        init?(parsing value: String) {
            let parts = value.split(separator: ".", omittingEmptySubsequences: false)
            guard (2...3).contains(parts.count),
                  parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy({ $0.isASCII && $0.isNumber }) }),
                  let major = Int(parts[0]),
                  let minor = Int(parts[1]) else {
                return nil
            }
            let patch: Int
            if parts.count == 3 {
                guard let parsed = Int(parts[2]) else { return nil }
                patch = parsed
            } else {
                patch = 0
            }
            self.init(major: major, minor: minor, patch: patch)
        }
    }
}

// MARK: - Comparable

extension WhatsNew.Version: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
}

// MARK: - CustomStringConvertible

extension WhatsNew.Version: CustomStringConvertible {
    public var description: String {
        "\(major).\(minor).\(patch)"
    }
}

// MARK: - ExpressibleByStringLiteral

extension WhatsNew.Version: ExpressibleByStringLiteral {
    /// Preserves the existing string-literal API. Invalid input maps to 0.0.0.
    public init(stringLiteral value: String) {
        self = Self(parsing: value) ?? Self(major: 0, minor: 0, patch: 0)
    }
}

// MARK: - Current

public extension WhatsNew.Version {
    static func current(in bundle: Bundle = .main) -> WhatsNew.Version {
        let shortVersionString = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        return .init(stringLiteral: shortVersionString ?? "")
    }
}
