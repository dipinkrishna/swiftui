//
//  CustomNavigationBar.swift
//
//  A custom top bar for SwiftUI screens.
//
//  Reach for .navigationTitle + .toolbar first. Hiding the system bar also
//  switches off swipe-to-go-back, and there is no public API to get it back,
//  so this is best on sheets and on the root of a stack.
//
//  Article: https://dipinkrishna.com/blog/2023/08/swiftui-create-a-custom-navigation-bar/
//  Requires iOS 17.
//

import SwiftUI

enum CustomNavigationBarTitleDisplayMode {
    case inline
    case large
}

extension View {
    /// Hides the system navigation bar and pins a custom one to the top safe area.
    ///
    /// On a pushed screen the Back button still works, but swiping back does
    /// not - UIKit turns the gesture off whenever the bar is hidden.
    func customNavigationBar<Title: View, Leading: View, Trailing: View>(
        titleDisplayMode: CustomNavigationBarTitleDisplayMode = .inline,
        foreground: Color = .primary,
        background: some ShapeStyle = .bar,
        @ViewBuilder title: () -> Title,
        @ViewBuilder leading: () -> Leading = { NavigationBackButton() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) -> some View {
        toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                CustomNavigationBar(
                    titleDisplayMode: titleDisplayMode,
                    title: title,
                    leading: leading,
                    trailing: trailing
                )
                .foregroundStyle(foreground)
                .tint(foreground)
                .background(background, ignoresSafeAreaEdges: .top)
            }
    }
}

struct CustomNavigationBar<Title: View, Leading: View, Trailing: View>: View {
    var titleDisplayMode: CustomNavigationBarTitleDisplayMode = .inline
    @ViewBuilder var title: Title
    @ViewBuilder var leading: Leading
    @ViewBuilder var trailing: Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BarLayout {
                HStack(spacing: 16) { leading }
                    .layoutValue(key: BarSlotKey.self, value: .leading)

                if titleDisplayMode == .inline {
                    title
                        .font(.headline)
                        .lineLimit(1)
                        .accessibilityAddTraits(.isHeader)
                        .layoutValue(key: BarSlotKey.self, value: .title)
                }

                HStack(spacing: 16) { trailing }
                    .layoutValue(key: BarSlotKey.self, value: .trailing)
            }
            .frame(minHeight: 44)

            if titleDisplayMode == .large {
                title
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                    .padding(.bottom, 8)
            }
        }
        .padding(.horizontal)
    }
}

/// Pops the current screen. Renders nothing on the root of a stack.
struct NavigationBackButton: View {
    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if isPresented {
            Button {
                dismiss()
            } label: {
                // At large text sizes, drop the word and keep the chevron.
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 4) {
                        chevron
                        Text("Back").lineLimit(1)
                    }
                    chevron
                }
            }
            .accessibilityLabel("Back")
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.backward").fontWeight(.semibold)
    }
}

private enum BarSlot {
    case leading, title, trailing
}

private struct BarSlotKey: LayoutValueKey {
    static let defaultValue = BarSlot.title
}

/// Leading and trailing hug the edges. The title stays centred on the bar
/// and truncates before it can run into either side.
private struct BarLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let bar = measure(width: proposal.width, subviews: subviews)
        return CGSize(width: bar.width, height: bar.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let bar = measure(width: bounds.width, subviews: subviews)

        for subview in subviews {
            let slot = subview[BarSlotKey.self]
            let (x, anchor): (CGFloat, UnitPoint) = switch slot {
            case .leading: (bounds.minX, .leading)
            case .title: (bounds.midX, .center)
            case .trailing: (bounds.maxX, .trailing)
            }
            subview.place(
                at: CGPoint(x: x, y: bounds.midY),
                anchor: anchor,
                proposal: ProposedViewSize(bar.sizes[slot] ?? .zero)
            )
        }
    }

    private func measure(width: CGFloat?, subviews: Subviews) -> (sizes: [BarSlot: CGSize], width: CGFloat, height: CGFloat) {
        func size(of slot: BarSlot, maxWidth: CGFloat) -> CGSize {
            subviews.first { $0[BarSlotKey.self] == slot }?
                .sizeThatFits(ProposedViewSize(width: maxWidth, height: nil)) ?? .zero
        }

        let available = width ?? .infinity

        // Each side may use up to a third of the bar...
        let leading = size(of: .leading, maxWidth: available / 3)
        let trailing = size(of: .trailing, maxWidth: available / 3)

        // ...and the title gets what is left after reserving the wider side on
        // *both* edges. That reservation is what keeps it centred.
        let side = max(leading.width, trailing.width)
        let title = size(of: .title, maxWidth: max(0, available - 2 * (side + spacing)))

        return (
            [.leading: leading, .title: title, .trailing: trailing],
            width ?? 2 * (side + spacing) + title.width,
            max(leading.height, title.height, trailing.height)
        )
    }
}

#Preview("Sheet header") {
    Text("Behind the sheet")
        .sheet(isPresented: .constant(true)) {
            List(1...30, id: \.self) { row in
                Text("Row \(row)")
            }
            .customNavigationBar(
                titleDisplayMode: .large,
                foreground: .white,
                background: .green
            ) {
                Text("Title")
            } leading: {
                EmptyView()
            } trailing: {
                Button("Done") {}
            }
        }
}

