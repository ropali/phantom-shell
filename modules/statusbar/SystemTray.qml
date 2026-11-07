import QtQuick
import "../../services" as Services
import "../../themes"

Row {
    id: root
    spacing: Theme.spacing.xs
    visible: repeater.count > 0

    Repeater {
        id: repeater
        model: Services.SystemTray.items

        delegate: Item {
            id: trayItem
            required property var modelData

            readonly property var item: modelData
            readonly property bool hasIcon: item && item.icon !== ""

            width: Theme.buttonSize
            height: Theme.buttonSize

            Image {
                anchors.centerIn: parent
                width: Theme.trayIconSize
                height: Theme.trayIconSize
                visible: trayItem.hasIcon
                source: trayItem.item ? trayItem.item.icon : ""
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
            }

            Text {
                anchors.centerIn: parent
                visible: !trayItem.hasIcon
                text: "\uf009"
                color: Theme.foreground
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.iconSize
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: (mouse) => {
                    if (!trayItem.item)
                        return;
                    if (mouse.button === Qt.RightButton) {
                        if (trayItem.item.hasMenu)
                            trayMenu.toggleMenu(trayItem.item.menu);
                        else
                            trayItem.item.secondaryActivate();
                    } else {
                        if (trayItem.item.onlyMenu && trayItem.item.hasMenu)
                            trayMenu.toggleMenu(trayItem.item.menu);
                        else
                            trayItem.item.activate();
                    }
                }
                onWheel: (wheel) => {
                    if (trayItem.item)
                        trayItem.item.scroll(wheel.angleDelta.y, false);
                }
            }

            TrayMenu {
                id: trayMenu
                anchorItem: trayItem
                menuHandle: trayItem.item ? trayItem.item.menu : null
            }
        }
    }
}
