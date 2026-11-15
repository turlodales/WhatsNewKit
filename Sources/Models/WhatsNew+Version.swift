
import Foundation

// MARK: - WhatsNew+Version

public extension WhatsNew {

    /// Represents an application release version.
    ///
    /// Supports traditional versions:
    /// - 1.0
    /// - 1.2.3
    ///
    /// Also supports calendar-based versions:
    /// - 2026.11
    /// - 2026.12
    /// - 2027.01
    /// - 2027.01.1
    struct Version: Hashable, Sendable {

        // MARK: - Properties

        /// Major version or release year.
        public var major: Int

        /// Minor version or release month.
        public var minor: Int

        /// Patch version.
        public var patch: Int

        // MARK: - Initializer

        /// Creates a version from numeric components.
        ///
        /// This initializer retains compatibility with
        /// existing WhatsNewKit applications.
        public init(
            major: Int,
            minor: Int,
            patch: Int = 0
        ) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        // MARK: - Validation

        /// Whether all version components are nonnegative.
        public var isValid: Bool {
            major >= 0 &&
            minor >= 0 &&
            patch >= 0
        }

        /// Whether this version uses calendar-based numbering.
        ///
        /// This identifies values shaped like YYYY.MM.
        public var isCalendarVersion: Bool {
            (2000...9999).contains(major) &&
            (1...12).contains(minor) &&
            patch >= 0
        }

        /// Release year, if using calendar-based numbering.
        public var releaseYear: Int? {
            isCalendarVersion ? major : nil
        }

        /// Release month, if using calendar-based numbering.
        public var releaseMonth: Int? {
            isCalendarVersion ? minor : nil
        }

        // MARK: - Version Parsing

        /// Parses a version string.
        ///
        /// Accepted formats:
        /// - "1"
        /// - "1.0"
        /// - "1.0.0"
        /// - "2027.01"
        /// - "2027.01.1"
        ///
        /// Returns nil for malformed versions.
        public init?(parsing string: String) {

            let value = string.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            let components = value.split(
                separator: ".",
                omittingEmptySubsequences: false
            )

            guard (1...3).contains(components.count) else {
                return nil
            }

            let numbers = components.compactMap { component -> Int? in
                guard !component.isEmpty,
                      component.allSatisfy({
                          $0 >= "0" && $0 <= "9"
                      }),
                      let number = Int(component),
                      number >= 0
                else {
                    return nil
                }

                return number
            }

            guard numbers.count == components.count else {
                return nil
            }

            self.major = numbers[0]
            self.minor = numbers.count > 1 ? numbers[1] : 0
            self.patch = numbers.count > 2 ? numbers[2] : 0
        }

        // MARK: - Release Helpers

        /// Returns the version without its patch component.
        public var baseVersion: Self {
            Self(
                major: major,
                minor: minor,
                patch: 0
            )
        }

        /// Whether this is a patch release.
        public var isPatchRelease: Bool {
            patch > 0
        }

        /// Returns a new version with the specified patch.
        public func withPatch(_ patch: Int) -> Self {
            Self(
                major: major,
                minor: minor,
                patch: patch
            )
        }

        /// A display version that omits a zero patch.
        ///
        /// Examples:
        /// - 2027.1.0 -> 2027.01
        /// - 2027.1.2 -> 2027.01.2
        /// - 1.2.0 -> 1.2
        public var displayVersion: String {
            let minorText = isCalendarVersion
                ? String(format: "%02d", minor)
                : String(minor)

            let base = "\(major).\(minorText)"

            return patch == 0
                ? base
                : "\(base).\(patch)"
        }
    }
}

// MARK: - Comparable

extension WhatsNew.Version: Comparable {

    /// Compares version components numerically.
    public static func < (
        lhs: Self,
        rhs: Self
    ) -> Bool {

        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }

        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }

        return lhs.patch < rhs.patch
    }
}

// MARK: - CustomStringConvertible

extension WhatsNew.Version: CustomStringConvertible {

    /// Canonical three-part representation.
    ///
    /// This stays compatible with the existing
    /// WhatsNewKit version stores and keys.
    public var description: String {
        "\(major).\(minor).\(patch)"
    }
}

// MARK: - ExpressibleByStringLiteral

extension WhatsNew.Version: ExpressibleByStringLiteral {

    /// Allows versions to be declared using string literals.
    ///
    /// Example:
    /// let version: WhatsNew.Version = "2027.01"
    ///
    /// Invalid literals fall back to 0.0.0 to preserve
    /// the previous nonfailable initializer behaviour.
    /// Use init?(parsing:) for external or untrusted input.
    public init(stringLiteral value: String) {
        self = Self(parsing: value) ??
            Self(major: 0, minor: 0, patch: 0)
    }
}

// MARK: - Current Application Version

public extension WhatsNew.Version {

    /// Returns the current application version
    /// from CFBundleShortVersionString.
    ///
    /// Returns 0.0.0 if the value is unavailable
    /// or cannot be parsed.
    static func current(
        in bundle: Bundle = .main
    ) -> Self {

        guard let versionString = bundle.infoDictionary?[
            "CFBundleShortVersionString"
        ] as? String else {
            return Self(major: 0, minor: 0, patch: 0)
        }

        return Self(parsing: versionString) ??
            Self(major: 0, minor: 0, patch: 0)
    }
}
