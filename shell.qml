import QtQuick
import Quickshell
import "components"
import "modules/statusbar"
import "modules/wallpaper"

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
