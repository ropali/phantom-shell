import QtQuick
import Quickshell
import Quickshell.Io

FileView {
    id: root

    property var modelData
    property string sourcePath: ""
    signal themeLoaded(var theme)
    signal themeLoadFailed(string path, string reason)

    path: sourcePath
    blockLoading: true
    watchChanges: false

    onLoaded: root.parse()

    function isColor(value) {
        return typeof value === "string" && /^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(value);
    }

    function isNumber(value) {
        return typeof value === "number" && isFinite(value);
    }

    function validate(data) {
        if (!data || typeof data !== "object")
            return null;

        if (typeof data.id !== "string" || !/^[a-z0-9-]+$/.test(data.id))
            return null;
        if (typeof data.name !== "string" || data.name.length === 0)
            return null;

        const colors = data.colors;
        const typography = data.typography;
        const spacing = data.spacing;
        const components = data.components;
        const animation = data.animation;
        if (!colors || !typography || !spacing || !components || !animation)
            return null;

        const colorKeys = [
            "background", "surface", "surfaceElevated", "primary", "secondary",
            "tertiary", "foreground", "mutedForeground", "disabled", "border",
            "success", "warning", "error", "info", "onPrimary", "onSecondary", "onTertiary"
        ];
        for (let i = 0; i < colorKeys.length; i++) {
            if (!root.isColor(colors[colorKeys[i]]))
                return null;
        }

        if (typeof typography.fontFamily !== "string" || typeof typography.iconFontFamily !== "string")
            return null;

        const typeNumbers = [
            "sizeTiny", "sizeSmall", "sizeBase", "sizeMedium", "size",
            "sizeLarge", "sizeXLarge", "weightNormal", "weightMedium", "weightBold", "lineHeight"
        ];
        for (let i = 0; i < typeNumbers.length; i++) {
            if (!root.isNumber(typography[typeNumbers[i]]))
                return null;
        }

        const spacingKeys = ["xs", "sm", "md", "lg", "xl"];
        for (let i = 0; i < spacingKeys.length; i++) {
            if (!root.isNumber(spacing[spacingKeys[i]]))
                return null;
        }

        const componentKeys = [
            "radius", "radiusSmall", "radiusLarge", "borderWidth", "padding",
            "opacity", "buttonSize", "iconSize", "trayIconSize",
            "workspaceButtonSize", "controlHeight", "rowHeight"
        ];
        for (let i = 0; i < componentKeys.length; i++) {
            if (!root.isNumber(components[componentKeys[i]]))
                return null;
        }
        if (typeof components.shadow !== "boolean")
            return null;

        const animationKeys = ["fast", "normal", "slow"];
        for (let i = 0; i < animationKeys.length; i++) {
            if (!root.isNumber(animation[animationKeys[i]]))
                return null;
        }
        if (typeof animation.easing !== "string")
            return null;

        return {
            id: data.id,
            name: data.name,
            colors: colors,
            typography: typography,
            spacing: spacing,
            components: components,
            animation: animation
        };
    }

    function parse() {
        if (!sourcePath || sourcePath.length === 0)
            return;

        const text = root.text();
        if (!text || text.length === 0) {
            root.themeLoadFailed(sourcePath, "theme file is empty");
            return;
        }

        let data;
        try {
            data = JSON.parse(text);
        } catch (error) {
            root.themeLoadFailed(sourcePath, "invalid JSON: " + error);
            return;
        }

        const theme = root.validate(data);
        if (!theme) {
            root.themeLoadFailed(sourcePath, "theme does not match the required schema");
            return;
        }

        root.themeLoaded(theme);
    }
}
