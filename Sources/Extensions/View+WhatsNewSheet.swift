import SwiftUI

// MARK: - Manual presentation

public extension View {

    /// Presents a What's New sheet for a manually supplied release.
    /// When a version store is provided, already-acknowledged releases are skipped.
    /// The caller owns the binding and may set a new release to present it again.
    func sheet(
        whatsNew: Binding<WhatsNew?>,
        versionStore: WhatsNewVersionStore? = nil,
        layout: WhatsNew.Layout = .default,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(
            ManualWhatsNewSheetViewModifier(
                whatsNew: whatsNew,
                versionStore: versionStore,
                layout: layout,
                onDismiss: onDismiss
            )
        )
    }
}

private struct ManualWhatsNewSheetViewModifier: ViewModifier {
    let whatsNew: Binding<WhatsNew?>
    let versionStore: WhatsNewVersionStore?
    let layout: WhatsNew.Layout
    let onDismiss: (() -> Void)?

    /// Keep the same sheet modifier installed even when no release is eligible.
    /// This avoids replacing the host view when the version store changes.
    private var eligibleRelease: Binding<WhatsNew?> {
        Binding(
            get: {
                guard let release = whatsNew.wrappedValue,
                      versionStore?.hasPresented(release.version) != true else {
                    return nil
                }
                return release
            },
            set: { whatsNew.wrappedValue = $0 }
        )
    }

    func body(content: Content) -> some View {
        content.sheet(
            item: eligibleRelease,
            onDismiss: onDismiss
        ) { release in
            WhatsNewView(
                whatsNew: release,
                versionStore: versionStore,
                layout: layout
            )
        }
    }
}

// MARK: - Automatic presentation

public extension View {

    /// Automatically presents the latest eligible release once per view lifetime.
    /// Swipe-dismissed releases remain unacknowledged and are eligible on a later
    /// app launch. The Continue button in WhatsNewView records acknowledgement.
    func whatsNewSheet(
        layout: WhatsNew.Layout? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(
            AutomaticWhatsNewSheetViewModifier(
                layout: layout,
                onDismiss: onDismiss
            )
        )
    }
}

private struct AutomaticWhatsNewSheetViewModifier: ViewModifier {
    let layout: WhatsNew.Layout?
    let onDismiss: (() -> Void)?

    @Environment(\.whatsNew) private var whatsNewEnvironment
    @State private var activeRelease: WhatsNew?
    @State private var hasCheckedForRelease = false

    func body(content: Content) -> some View {
        content
            .sheet(item: $activeRelease, onDismiss: onDismiss) { release in
                WhatsNewView(
                    whatsNew: release,
                    versionStore: whatsNewEnvironment.whatsNewVersionStore,
                    layout: layout ?? whatsNewEnvironment.defaultLayout
                )
            }
            .onAppear {
                guard !hasCheckedForRelease else { return }
                hasCheckedForRelease = true
                activeRelease = whatsNewEnvironment.whatsNew()
            }
    }
}
