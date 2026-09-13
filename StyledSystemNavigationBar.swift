//
//  StyledSystemNavigationBar.swift
//
//  Styling the system navigation bar instead of hiding it, so swipe to go back
//  keeps working. For sheets, full-screen covers and the root of a stack, where
//  a fully custom bar is fine, see CustomNavigationBar.swift.
//
//  Article: https://dipinkrishna.com/blog/2026/09/swiftui-navigation-bar-ios-26/
//  Requires iOS 17. The glass helper does nothing before iOS 26.
//

import SwiftUI

extension ToolbarContent {
    /// Removes the Liquid Glass capsule iOS 26 draws behind a toolbar item.
    /// Does nothing on earlier versions.
    @ToolbarContentBuilder
    func glassHiddenIfAvailable() -> some ToolbarContent {
        if #available(iOS 26.0, *) {
            sharedBackgroundVisibility(.hidden)
        } else {
            self
        }
    }
}

/// A black bar with a custom title view and a plain Save button, drawn by the
/// system. The Back button and the swipe back both come from the system.
///
/// On iOS 26 the status bar wasn't visible over this black background in
/// testing (iOS 18 draws it white), so check a dark bar on iOS 26 before
/// shipping one.
struct StyledSystemNavigationBarExample: View {
    var body: some View {
        List(1...40, id: \.self) { row in
            Text("Row \(row)")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Title")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {}
                    .tint(.white)
            }
            .glassHiddenIfAvailable()
        }
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

/// A title with a subtitle in the principal slot. On iOS 26 and later,
/// .navigationTitle plus .navigationSubtitle(_:) does the same job.
struct SubtitledSystemNavigationBarExample: View {
    var body: some View {
        List(1...40, id: \.self) { row in
            Text("Row \(row)")
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text("Title")
                        .font(.headline)
                    Text("3 unsaved changes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {}
            }
        }
    }
}

#Preview("Styled system bar") {
    NavigationStack {
        List {
            NavigationLink("Black bar") {
                StyledSystemNavigationBarExample()
            }
            NavigationLink("Title and subtitle") {
                SubtitledSystemNavigationBarExample()
            }
        }
        .navigationTitle("Screens")
    }
}
