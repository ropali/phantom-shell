import QtQuick
import "../../../themes"
import "../../../config" as Config
import "../../../components" as Components

Components.SettingsPage {
    title: "Appearance"
    icon: "\uf1fc"
    description: "Change the active theme and fine-tune typography, shape, transparency and motion."

    Components.SettingsCard {
        title: "Theme"
        description: "The selected theme is applied to every Phantom surface immediately."

        Components.ThemePicker {
            width: parent.width
            height: implicitHeight
        }

        Components.SettingsTextField {
            value: Config.Settings.externalThemeHook
            placeholder: "Optional command to run after a theme change"
            onEdited: (text) => {
                Config.Settings.externalThemeHook = text;
                Config.Settings.scheduleSave();
            }
        }
    }

    Components.SettingsCard {
        title: "Typography"
        description: "These overrides sit on top of the active theme."

        Components.SettingsTextField {
            value: Config.Settings.fontFamilyOverride
            placeholder: "Font family (leave empty to use the theme)"
            onEdited: (text) => {
                Config.Settings.fontFamilyOverride = text;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsSliderRow {
            title: "Text scale"
            valueText: Math.round(Config.Settings.uiScale * 100) + "%"
            value: Config.Settings.uiScale
            from: 0.8
            to: 1.3
            onMoved: (value) => {
                Config.Settings.uiScale = value;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsSliderRow {
            title: "Corner radius"
            valueText: Config.Settings.radiusScale.toFixed(2) + "×"
            value: Config.Settings.radiusScale
            from: 0.5
            to: 1.5
            onMoved: (value) => {
                Config.Settings.radiusScale = value;
                Config.Settings.scheduleSave();
            }
        }
    }

    Components.SettingsCard {
        title: "Effects"

        Components.SettingsSliderRow {
            title: "Surface opacity"
            description: "Affects bar and popup backgrounds."
            valueText: Math.round(Config.Settings.shellOpacity * 100) + "%"
            value: Config.Settings.shellOpacity
            from: 0.5
            to: 1.0
            onMoved: (value) => {
                Config.Settings.shellOpacity = value;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsToggleRow {
            title: "Animations"
            description: "Disable all Phantom transitions."
            checked: Config.Settings.animationsEnabled
            onToggled: {
                Config.Settings.animationsEnabled = !Config.Settings.animationsEnabled;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsSliderRow {
            title: "Animation speed"
            valueText: Config.Settings.animationScale.toFixed(2) + "×"
            value: Config.Settings.animationScale
            from: 0.5
            to: 2.0
            isEnabled: Config.Settings.animationsEnabled
            onMoved: (value) => {
                Config.Settings.animationScale = value;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsButton {
            text: "Reset appearance"
            icon: "\uf2ea"
            onClicked: Config.Settings.resetAppearance()
        }
    }
}
