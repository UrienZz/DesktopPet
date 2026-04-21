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
            backgroundOpacity = 0.26
            borderOpacity = 0.24
            iconTileOpacity = 0.28
            indicatorOpacity = 1
            shadowOpacity = 0.14
        case (true, false):
            backgroundOpacity = 0.22
            borderOpacity = 0.2
            iconTileOpacity = 0.24
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

struct SettingsPageBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(nsColor: .windowBackgroundColor),
                Color(nsColor: .underPageBackgroundColor).opacity(0.96),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topLeading) {
            RadialGradient(
                colors: [
                    Color.accentColor.opacity(0.12),
                    .clear,
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 380
            )
            .frame(width: 520, height: 420)
        }
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

struct SettingsHeroCard<Accessory: View, Actions: View>: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    @ViewBuilder let accessory: Accessory
    @ViewBuilder let actions: Actions

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 14) {
                Text(eyebrow)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 32, weight: .bold))
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }

                actions
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            accessory
                .frame(minWidth: 220, alignment: .trailing)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.92),
                            Color.white.opacity(0.8),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.75), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.07), radius: 24, y: 14)
    }
}

struct SettingsSectionCard<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    var prominence: SettingsCardProminence = .standard
    @ViewBuilder let content: Content

    var body: some View {
        let backgroundOpacity = prominence == .featured ? 0.9 : 0.78
        let borderOpacity = prominence == .featured ? 0.12 : 0.08
        let shadowOpacity = prominence == .featured ? 0.08 : 0.05

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
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(backgroundOpacity))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.72), lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.black.opacity(borderOpacity), lineWidth: 0.6)
        )
        .shadow(color: .black.opacity(shadowOpacity), radius: 18, y: 10)
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
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(appearance.indicatorOpacity))
                    .frame(width: 4, height: 32)

                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor.opacity(appearance.iconTileOpacity))
                    .frame(width: 34, height: 34)
                    .overlay {
                        Image(systemName: pane.systemImage)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isSelected ? Color.accentColor : Color.primary.opacity(isHovered ? 0.82 : 0.66))
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(pane.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.primary : Color.primary.opacity(isHovered ? 0.92 : 0.8))

                    Text(pane.sidebarSubtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 10)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary.opacity(isHovered ? 0.8 : 0.44))
                    .offset(x: isHovered ? 1.5 : 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.accentColor.opacity(appearance.backgroundOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.accentColor.opacity(appearance.borderOpacity), lineWidth: 1)
            )
            .shadow(color: .black.opacity(appearance.shadowOpacity), radius: isHovered ? 12 : 8, y: isHovered ? 6 : 4)
        }
        .buttonStyle(SettingsSidebarButtonStyle(isSelected: isSelected, isHovered: isHovered))
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
