import QtQuick
import QtQuick.Layouts
import "../../../themes"
import "../../../config" as Config
import "../../../components" as Components

Column {
    id: view

    readonly property int rowHeight: 52
    readonly property int preferredHeight: implicitHeight
    property int dropIndex: -1

    anchors.fill: parent
    spacing: Theme.spacing.md

    function iconFor(id) {
        if (id === "notifications") return "\uf0f3";
        if (id === "network") return "\uf1eb";
        if (id === "bluetooth") return "\uf293";
        if (id === "audio") return "\uf028";
        if (id === "power") return "\uf011";
        return "\uf111";
    }

    function titleFor(id) {
        if (id === "notifications") return "Notifications";
        if (id === "network") return "Network";
        if (id === "bluetooth") return "Bluetooth";
        if (id === "audio") return "Volume";
        if (id === "power") return "Power";
        return id;
    }

    function subtitleFor(id) {
        if (id === "notifications") return "Notification center and Do Not Disturb";
        if (id === "network") return "Wi-Fi and Ethernet status";
        if (id === "bluetooth") return "Adapter and device status";
        if (id === "audio") return "Output volume and audio devices";
        if (id === "power") return "Session and power menu";
        return "";
    }

    Text {
        width: parent.width
        text: "Choose which controls appear in the control center group. Drag the grip here or the icons on the bar to reorder them."
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
        lineHeight: Theme.lineHeight
    }

    RowLayout {
        width: parent.width
        spacing: Theme.spacing.md

        Column {
            Layout.fillWidth: true
            spacing: 1

            Text {
                width: parent.width
                text: "Control center position"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBase
                font.weight: Theme.fontWeightBold
            }

            Text {
                width: parent.width
                text: "Move the whole group to the left or right side of the bar"
                color: Theme.mutedForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }
        }

        Rectangle {
            id: positionControl
            Layout.preferredWidth: 96
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.radiusSmall
            color: Theme.surface
            border.width: Theme.borderWidth
            border.color: Theme.subtleBorder

            Row {
                anchors.fill: parent
                anchors.margins: 2
                spacing: 2

                Rectangle {
                    width: (positionControl.width - 6) / 2
                    height: parent.height
                    radius: Theme.radiusSmall
                    color: Config.Settings.barControlCenterPosition === "left"
                        ? Theme.primary : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Left"
                        color: Config.Settings.barControlCenterPosition === "left"
                            ? Theme.onPrimary : Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Theme.fontWeightBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Config.Settings.setBarControlCenterPosition("left")
                    }
                }

                Rectangle {
                    width: (positionControl.width - 6) / 2
                    height: parent.height
                    radius: Theme.radiusSmall
                    color: Config.Settings.barControlCenterPosition === "right"
                        ? Theme.primary : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Right"
                        color: Config.Settings.barControlCenterPosition === "right"
                            ? Theme.onPrimary : Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Theme.fontWeightBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Config.Settings.setBarControlCenterPosition("right")
                    }
                }
            }
        }
    }

    Column {
        id: listColumn
        width: parent.width
        spacing: Theme.spacing.sm

        Repeater {
            model: Config.Settings.barLayout

            delegate: Item {
                id: row

                required property var modelData
                required property int index

                width: listColumn.width
                height: view.rowHeight
                z: dragMouse.drag.active ? 100 : 0

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    color: rowHover.hovered ? Theme.surface : "transparent"
                    border.width: view.dropIndex === row.index ? 2 : 0
                    border.color: Theme.primary

                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
                    }
                }

                HoverHandler {
                    id: rowHover
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.sm
                    anchors.rightMargin: Theme.spacing.md
                    spacing: Theme.spacing.sm

                    Item {
                        id: dragHandle
                        Layout.preferredWidth: 22
                        Layout.fillHeight: true

                        Text {
                            anchors.centerIn: parent
                            text: "\uf0c9"
                            color: dragMouse.containsMouse ? Theme.foreground : Theme.mutedForeground
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.fontSizeBase
                        }

                        MouseArea {
                            id: dragMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.SizeVerCursor
                            drag.target: ghost
                            drag.axis: Drag.YAxis
                            drag.minimumY: -row.y
                            drag.maximumY: listColumn.height - row.height - row.y

                            onPressed: ghost.y = 0

                            onPositionChanged: {
                                if (!dragMouse.drag.active)
                                    return;
                                const step = view.rowHeight + listColumn.spacing;
                                let target = Math.round((row.y + ghost.y) / step);
                                target = Math.max(0, Math.min(Config.Settings.barLayout.length - 1, target));
                                view.dropIndex = target;
                            }

                            onReleased: {
                                const step = view.rowHeight + listColumn.spacing;
                                let target = Math.round((row.y + ghost.y) / step);
                                target = Math.max(0, Math.min(Config.Settings.barLayout.length - 1, target));
                                view.dropIndex = -1;
                                ghost.y = 0;
                                if (target !== row.index) {
                                    const sourceIndex = row.index;
                                    Qt.callLater(() => Config.Settings.moveBarItem(sourceIndex, target));
                                }
                            }
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: view.iconFor(row.modelData.id)
                        color: Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeMedium
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: view.titleFor(row.modelData.id)
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBase
                            font.weight: Theme.fontWeightBold
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: view.subtitleFor(row.modelData.id)
                            color: Theme.mutedForeground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            elide: Text.ElideRight
                        }
                    }

                    Components.ToggleSwitch {
                        Layout.alignment: Qt.AlignVCenter
                        checked: row.modelData.visible
                        onToggled: {
                            const id = row.modelData.id;
                            const visible = !row.modelData.visible;
                            Qt.callLater(() => Config.Settings.setBarItemVisible(id, visible));
                        }
                    }
                }

                Rectangle {
                    id: ghost
                    width: row.width
                    height: row.height
                    radius: Theme.radiusSmall
                    color: Theme.surfaceElevated
                    border.width: Theme.borderWidth
                    border.color: Theme.accentBorder
                    opacity: 0.96
                    visible: dragMouse.drag.active
                    z: 100

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacing.sm + Theme.spacing.xs
                        anchors.rightMargin: Theme.spacing.md
                        spacing: Theme.spacing.sm

                        Text {
                            text: view.iconFor(row.modelData.id)
                            color: Theme.primary
                            font.family: Theme.iconFontFamily
                            font.pixelSize: Theme.fontSizeMedium
                        }

                        Text {
                            Layout.fillWidth: true
                            text: view.titleFor(row.modelData.id)
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeBase
                            font.weight: Theme.fontWeightBold
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: Theme.borderWidth
        color: Theme.subtleBorder
    }

    Text {
        width: parent.width
        text: "You can drag the icons directly on the status bar to reorder them. The system tray and control center button stay pinned at the ends of the group."
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
        lineHeight: Theme.lineHeight
    }
}
