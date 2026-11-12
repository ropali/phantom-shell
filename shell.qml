import QtQuick
import Quickshell
import Quickshell.Io
import "components"
import "services" as Services
import "modules/statusbar"
import "modules/wallpaper"
import "modules/nightlight"
import "modules/controlcenter"
import "modules/settings"

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            Wallpaper {
                screen: modelData
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            NightLightOverlay {
                screen: modelData
            }
        }
    }

    ControlCenterKeys {}

    SettingsWindow {}

    IpcHandler {
        target: "phantom"

        function settings() {
            Services.UiState.openSettings();
        }

        function toggleSettings() {
            Services.UiState.toggleSettings();
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            ClickCatcher {
                screen: modelData
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            StatusBar {
                screen: modelData
            }
        }
    }
}
