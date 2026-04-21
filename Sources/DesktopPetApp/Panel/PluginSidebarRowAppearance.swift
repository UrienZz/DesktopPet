import Foundation

struct PluginSidebarRowAppearance: Equatable {
    let backgroundOpacity: Double
    let borderOpacity: Double
    let leadingIndicatorOpacity: Double
    let iconTileOpacity: Double
    let shadowOpacity: Double
    let scale: Double

    static func resolve(isSelected: Bool, isHovered: Bool, isPressed: Bool) -> Self {
        let backgroundOpacity: Double
        let borderOpacity: Double
        let leadingIndicatorOpacity: Double
        let iconTileOpacity: Double
        let shadowOpacity: Double

        switch (isSelected, isHovered) {
        case (true, true):
            backgroundOpacity = 0.26
            borderOpacity = 0.30
            leadingIndicatorOpacity = 1
            iconTileOpacity = 0.26
            shadowOpacity = 0.16
        case (true, false):
            backgroundOpacity = 0.22
            borderOpacity = 0.24
            leadingIndicatorOpacity = 0.92
            iconTileOpacity = 0.22
            shadowOpacity = 0.13
        case (false, true):
            backgroundOpacity = 0.12
            borderOpacity = 0.16
            leadingIndicatorOpacity = 0.48
            iconTileOpacity = 0.15
            shadowOpacity = 0.08
        case (false, false):
            backgroundOpacity = 0.03
            borderOpacity = 0.06
            leadingIndicatorOpacity = 0
            iconTileOpacity = 0.08
            shadowOpacity = 0.02
        }

        return Self(
            backgroundOpacity: backgroundOpacity,
            borderOpacity: borderOpacity,
            leadingIndicatorOpacity: leadingIndicatorOpacity,
            iconTileOpacity: iconTileOpacity,
            shadowOpacity: isPressed ? shadowOpacity * 0.55 : shadowOpacity,
            scale: isPressed ? 0.985 : 1
        )
    }
}
