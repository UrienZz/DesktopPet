import AppKit
import SwiftUI

struct SettingsSidebarItemAppearance: Equatable {
    let backgroundOpacity: Double
    let borderOpacity: Double
    let iconTileOpacity: Double
    let indicatorOpacity: Double
    let shadowOpacity: Double
    let scale: Double

    static func resolve(isSelected: Bool, isHovered: Bool, isPressed: Bool) -> Self {
        let backgroundOpacity: Double
        let borderOpacity: Double
        let iconTileOpacity: Double
        let indicatorOpacity: Double
        let shadowOpacity: Double

        switch (isSelected, isHovered) {
        case (true, true):
            backgroundOpacity = 1
            borderOpacity = 0.24
            iconTileOpacity = 0.18
            indicatorOpacity = 1
            shadowOpacity = 0.14
        case (true, false):
            backgroundOpacity = 1
            borderOpacity = 0.2
            iconTileOpacity = 0.16
            indicatorOpacity = 0.92
            shadowOpacity = 0.11
        case (false, true):
            backgroundOpacity = 0.11
            borderOpacity = 0.12
            iconTileOpacity = 0.14
            indicatorOpacity = 0.44
            shadowOpacity = 0.07
        case (false, false):
            backgroundOpacity = 0.025
            borderOpacity = 0.05
            iconTileOpacity = 0.07
            indicatorOpacity = 0
            shadowOpacity = 0.015
        }

        return Self(
            backgroundOpacity: backgroundOpacity,
            borderOpacity: borderOpacity,
            iconTileOpacity: iconTileOpacity,
            indicatorOpacity: indicatorOpacity,
            shadowOpacity: isPressed ? shadowOpacity * 0.55 : shadowOpacity,
            scale: isPressed ? 0.986 : 1
        )
    }
}

enum SettingsCardProminence {
    case standard
    case featured
}

enum SettingsSidebarLayout {
    static let width: CGFloat = 260
    static let outerPadding: CGFloat = 12
    static let containerWidth: CGFloat = width + (outerPadding * 2)
    static let horizontalPadding: CGFloat = 22
    static let topPadding: CGFloat = 112
    static let panelCornerRadius: CGFloat = 30
    static let panelShadowRadius: CGFloat = 26
    static let panelBackgroundOpacity: Double = 0.36
    static let panelShadowOpacity: Double = 0.08
    static let rowSpacing: CGFloat = 12
    static let rowHorizontalPadding: CGFloat = 14
    static let rowVerticalPadding: CGFloat = 12
    static let rowCornerRadius: CGFloat = 14
    static let iconSize: CGFloat = 32
    static let iconCornerRadius: CGFloat = 10
    static let titleFontSize: CGFloat = 16
}

struct SettingsPageBackground: View {
    var body: some View {
        Color(nsColor: .windowBackgroundColor)
            .ignoresSafeArea()
    }
}

struct SettingsInfoPill: View {
    let label: String
    let value: String
    var tint: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(tint.opacity(0.14), lineWidth: 1)
        )
    }
}

struct SettingsPageHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}

struct SettingsSectionCard<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var prominence: SettingsCardProminence = .standard
    @ViewBuilder let content: Content

    var body: some View {
        let backgroundOpacity = prominence == .featured ? 0.86 : 0.76
        let borderOpacity = prominence == .featured ? 0.1 : 0.06

        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(backgroundOpacity))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.black.opacity(borderOpacity), lineWidth: 0.6)
        )
    }
}

struct SettingsActionButtonStyle: ButtonStyle {
    @Environment(\.controlActiveState) private var controlActiveState

    let tint: Color
    var isFilled = true
    var graysWhenInactive = false

    func makeBody(configuration: Configuration) -> some View {
        let resolvedTint = graysWhenInactive && controlActiveState == .inactive
            ? Color(nsColor: .systemGray)
            : tint

        return configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(isFilled ? Color.white : resolvedTint)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isFilled ? resolvedTint.opacity(configuration.isPressed ? 0.84 : 1) : resolvedTint.opacity(configuration.isPressed ? 0.16 : 0.11))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(resolvedTint.opacity(isFilled ? 0.18 : 0.24), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SettingsSidebarPaneButton: View {
    let pane: SettingsPane
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false
    @State private var isPointerActive = false

    private var appearance: SettingsSidebarItemAppearance {
        SettingsSidebarItemAppearance.resolve(
            isSelected: isSelected,
            isHovered: isHovered,
            isPressed: false
        )
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: SettingsSidebarLayout.iconCornerRadius, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(appearance.iconTileOpacity) : Color.accentColor.opacity(appearance.iconTileOpacity))
                    .frame(width: SettingsSidebarLayout.iconSize, height: SettingsSidebarLayout.iconSize)
                    .overlay {
                        Image(systemName: pane.systemImage)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(isHovered ? 0.82 : 0.66))
                    }

                Text(pane.title)
                    .font(.system(size: SettingsSidebarLayout.titleFontSize, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : Color.primary.opacity(isHovered ? 0.92 : 0.8))

                Spacer(minLength: 8)
            }
            .padding(.horizontal, SettingsSidebarLayout.rowHorizontalPadding)
            .padding(.vertical, SettingsSidebarLayout.rowVerticalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: SettingsSidebarLayout.rowCornerRadius, style: .continuous)
                    .fill(isSelected ? Color.accentColor : Color.accentColor.opacity(appearance.backgroundOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: SettingsSidebarLayout.rowCornerRadius, style: .continuous)
                    .strokeBorder(Color.accentColor.opacity(appearance.borderOpacity), lineWidth: 1)
            )
            .shadow(color: .black.opacity(appearance.shadowOpacity), radius: isHovered ? 12 : 8, y: isHovered ? 6 : 4)
        }
        .buttonStyle(SettingsSidebarButtonStyle(isSelected: isSelected, isHovered: isHovered))
        .contentShape(RoundedRectangle(cornerRadius: SettingsSidebarLayout.rowCornerRadius, style: .continuous))
        .onHover(perform: updateHoverState)
        .onDisappear {
            if isPointerActive {
                NSCursor.pop()
                isPointerActive = false
            }
        }
        .animation(.easeOut(duration: 0.16), value: isHovered)
        .animation(.easeOut(duration: 0.16), value: isSelected)
    }

    private func updateHoverState(_ hovering: Bool) {
        isHovered = hovering

        if hovering {
            guard !isPointerActive else { return }
            NSCursor.pointingHand.push()
            isPointerActive = true
        } else if isPointerActive {
            NSCursor.pop()
            isPointerActive = false
        }
    }
}

private struct SettingsSidebarButtonStyle: ButtonStyle {
    let isSelected: Bool
    let isHovered: Bool

    func makeBody(configuration: Configuration) -> some View {
        let appearance = SettingsSidebarItemAppearance.resolve(
            isSelected: isSelected,
            isHovered: isHovered,
            isPressed: configuration.isPressed
        )

        return configuration.label
            .scaleEffect(appearance.scale)
            .brightness(configuration.isPressed ? -0.01 : 0)
    }
}
