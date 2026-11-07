import QtQuick
import "../../config" as Config
import "../../components" as Components
import "../../themes"

Row {
    id: root

    property var controller: null
    spacing: Theme.spacing.md
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    Component.onCompleted: if (controller) Qt.callLater(controller.updateControlCenterAnchor)
    onWidthChanged: if (controller) Qt.callLater(controller.updateControlCenterAnchor)

    SystemTray {
        anchors.verticalCenter: parent.verticalCenter
    }

    BarControls {
        anchors.verticalCenter: parent.verticalCenter
        controller: root.controller
    }

    Components.IconButton {
        id: controlCenterButton
        anchors.verticalCenter: parent.verticalCenter
        icon: "\uf1de"
        active: root.controller ? root.controller.isOpen("controlCenter") : false
        tooltip: "Control center"
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
}
