pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property var palette: ThemeManager.palette
    readonly property var colors: palette.colors
    readonly property var typography: palette.typography
    readonly property var spacing: palette.spacing
    readonly property var components: palette.components
    readonly property var animation: palette.animation

    readonly property color background: colors.background
    readonly property color surface: colors.surface
    readonly property color surfaceElevated: colors.surfaceElevated
    readonly property color primary: colors.primary
    readonly property color secondary: colors.secondary
    readonly property color tertiary: colors.tertiary
    readonly property color foreground: colors.foreground
    readonly property color mutedForeground: colors.mutedForeground
    readonly property color disabled: colors.disabled
    readonly property color border: colors.border
    readonly property color success: colors.success
    readonly property color warning: colors.warning
    readonly property color error: colors.error
    readonly property color info: colors.info
    readonly property color onPrimary: colors.onPrimary
    readonly property color onSecondary: colors.onSecondary
    readonly property color onTertiary: colors.onTertiary

    readonly property string fontFamily: typography.fontFamily
    readonly property string iconFontFamily: typography.iconFontFamily
    readonly property int fontSizeTiny: typography.sizeTiny
    readonly property int fontSizeSmall: typography.sizeSmall
    readonly property int fontSizeBase: typography.sizeBase
    readonly property int fontSizeMedium: typography.sizeMedium
    readonly property int fontSize: typography.size
    readonly property int fontSizeLarge: typography.sizeLarge
    readonly property int fontSizeXLarge: typography.sizeXLarge
    readonly property int fontWeightNormal: typography.weightNormal
    readonly property int fontWeightMedium: typography.weightMedium
    readonly property int fontWeightBold: typography.weightBold
    readonly property real lineHeight: typography.lineHeight

    readonly property int radius: components.radius
    readonly property int radiusSmall: components.radiusSmall
    readonly property int radiusLarge: components.radiusLarge
    readonly property int borderWidth: components.borderWidth
    readonly property int padding: components.padding
    readonly property real opacity: components.opacity
    readonly property int buttonSize: components.buttonSize
    readonly property int iconSize: components.iconSize
    readonly property int trayIconSize: components.trayIconSize
    readonly property int workspaceButtonSize: components.workspaceButtonSize
    readonly property int controlHeight: components.controlHeight
    readonly property int rowHeight: components.rowHeight
    readonly property bool shadow: components.shadow

    readonly property int animationFast: animation.fast
    readonly property int animationNormal: animation.normal
    readonly property int animationSlow: animation.slow

    readonly property int easingType: {
        switch (animation.easing) {
        case "Linear": return Easing.Linear;
        case "InQuad": return Easing.InQuad;
        case "OutQuad": return Easing.OutQuad;
        case "InOutQuad": return Easing.InOutQuad;
        case "InCubic": return Easing.InCubic;
        case "InOutCubic": return Easing.InOutCubic;
        case "InQuart": return Easing.InQuart;
        case "OutQuart": return Easing.OutQuart;
        case "InOutQuart": return Easing.InOutQuart;
        case "InSine": return Easing.InSine;
        case "OutSine": return Easing.OutSine;
        case "InOutSine": return Easing.InOutSine;
        case "InExpo": return Easing.InExpo;
        case "OutExpo": return Easing.OutExpo;
        case "InOutExpo": return Easing.InOutExpo;
        case "InCirc": return Easing.InCirc;
        case "OutCirc": return Easing.OutCirc;
        case "InOutCirc": return Easing.InOutCirc;
        case "InBack": return Easing.InBack;
        case "OutBack": return Easing.OutBack;
        case "InOutBack": return Easing.InOutBack;
        case "InBounce": return Easing.InBounce;
        case "OutBounce": return Easing.OutBounce;
        case "InOutBounce": return Easing.InOutBounce;
        default: return Easing.OutCubic;
        }
    }

    readonly property color barBackground: Qt.rgba(background.r, background.g, background.b, opacity)
    readonly property color popupBackground: Qt.rgba(background.r, background.g, background.b, Math.min(1, opacity + 0.04))
}
