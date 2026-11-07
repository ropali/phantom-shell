import QtQuick
import Quickshell
import "components"
import "modules/statusbar"
import "modules/wallpaper"
import "modules/nightlight"
import "modules/controlcenter"

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
