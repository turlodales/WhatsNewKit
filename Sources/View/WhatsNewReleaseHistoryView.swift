import SwiftUI

/// A read-only catalogue of releases up to the installed application version.
/// Opening an archived release does not mark it as acknowledged.
@available(iOS 14.0, macOS 11.0, visionOS 1.0, *)
public struct WhatsNewReleaseHistoryView: View {
    private let environment: WhatsNewEnvironment

    @State private var selectedRelease: WhatsNew?

    public init(environment: WhatsNewEnvironment) {
        self.environment = environment
    }

    public var body: some View {
        List {
            ForEach(environment.releaseHistory) { release in
                Button {
                    selectedRelease = release
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Version \(release.version.description)")
                                .font(.headline)
                            Text(release.title.text.attributedString.string)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View release \(release.version.description)")
            }
        }
        .navigationTitle("What's New")
        .sheet(item: $selectedRelease) { release in
            // No store is supplied, so reading history cannot acknowledge
            // a release or suppress a future automatic announcement.
            WhatsNewView(whatsNew: release, layout: environment.defaultLayout)
        }
    }
}
