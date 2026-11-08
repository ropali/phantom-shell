import QtQuick
import Quickshell
import "../../config" as Config
import "../../themes"
import "../../services" as Services

Item {
    id: root

    property var controller: null

    readonly property Region maskRegion: Region {
        Region { item: leftCluster }
        Region { item: clockPill }
        Region { item: rightCluster }
    }

    width: parent ? parent.width : 0
    height: Config.Settings.barHeight
    y: Config.Settings.barPosition === "bottom" ? parent.height - height : 0

    MouseArea {
        anchors.fill: parent
        onClicked: Services.UiState.dismissAll()
    }

    Row {
        id: leftCluster
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.xl
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.md

        BarRoundButton {
            icon: "\uf043"
            iconColor: Theme.primary
            tooltip: "Launcher"
            onClicked: Quickshell.execDetached(["hyprlauncher"])
        }

        BarPill {
            horizontalPadding: Theme.spacing.md
            WorkspacePager {}
        }

        BarPill {
            horizontalPadding: Theme.spacing.md
            PinnedApps {}
        }
    }

    ClockPill {
        id: clockPill
        anchors.centerIn: parent
    }

    Row {
        id: rightCluster
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.xl
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.md

        StatusPill {
            controller: root.controller
        }

        BarRoundButton {
            id: controlCenterButton
            icon: "\uf1de"
            tooltip: "Control center"
            active: root.controller ? root.controller.isOpen("controlCenter") : false
            onClicked: if (root.controller) root.controller.toggleControlCenter()

            Component.onCompleted: {
                if (root.controller)
                    root.controller.registerButton("controlCenter", controlCenterButton);
            }

            Component.onDestruction: {
                if (root.controller)
                    root.controller.unregisterButton("controlCenter", controlCenterButton);
            }
        }

        BarRoundButton {
            id: powerButton
            visible: Config.Settings.isBarItemVisible("power")
            icon: "\uf011"
            iconColor: Theme.error
            tooltip: "Power menu"
            active: root.controller ? root.controller.isOpen("power") : false
            onClicked: if (root.controller) root.controller.togglePowerMenu(false)

            Component.onCompleted: {
                if (root.controller)
                    root.controller.registerButton("power", powerButton);
            }

            Component.onDestruction: {
                if (root.controller)
                    root.controller.unregisterButton("power", powerButton);
            }
        }
    }
}
