import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../themes"

PanelWindow {
    id: root

    property var network: null
    property bool shown: false
    property bool passwordVisible: false

    signal submitted(var network, string psk)

    visible: shown

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    color: "transparent"
    aboveWindows: true
    focusable: true
    exclusiveZone: -1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "phantom-wifi-password"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onShownChanged: {
        if (shown) {
            pskInput.text = "";
            root.passwordVisible = false;
            Qt.callLater(() => pskInput.forceActiveFocus());
        }
    }

    function submit() {
        if (!network || pskInput.text.length === 0)
            return;
        root.submitted(network, pskInput.text);
        root.shown = false;
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.6)

        MouseArea {
            anchors.fill: parent
            onClicked: root.shown = false
        }
    }

    Rectangle {
        id: card

        width: 330
        height: content.implicitHeight + Theme.padding * 2
        anchors.centerIn: parent
        radius: Theme.radius
        color: Theme.popupBackground
        border.width: Theme.borderWidth
        border.color: Theme.border

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            id: content
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: Theme.spacing.md

            Text {
                width: parent.width
                text: "Connect to " + (root.network ? root.network.name : "")
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeightBold
                elide: Text.ElideRight
            }

            Rectangle {
                width: parent.width
                height: Theme.controlHeight
                radius: Theme.radiusSmall
                color: Theme.surface
                border.width: Theme.borderWidth
                border.color: pskInput.activeFocus ? Theme.primary : Theme.border

                TextInput {
                    id: pskInput
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.md
                    anchors.rightMargin: Theme.controlHeight
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBase
                    echoMode: root.passwordVisible ? TextInput.Normal : TextInput.Password
                    selectionColor: Theme.primary
                    selectedTextColor: Theme.onPrimary
                    onAccepted: root.submit()
                }

                Item {
                    id: revealButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.controlHeight
                    height: Theme.controlHeight

                    Text {
                        anchors.centerIn: parent
                        text: root.passwordVisible ? "\uf070" : "\uf06e"
                        color: revealMouse.containsMouse ? Theme.primary : Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        id: revealMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.passwordVisible = !root.passwordVisible;
                            pskInput.forceActiveFocus();
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: Theme.spacing.md
                layoutDirection: Qt.RightToLeft

                Rectangle {
                    width: 82
                    height: Theme.rowHeight
                    radius: Theme.radiusSmall
                    color: connectMouse.containsMouse ? Theme.surfaceElevated : Theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: Theme.primary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Theme.fontWeightBold
                    }

                    MouseArea {
                        id: connectMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.submit()
                    }
                }

                Rectangle {
                    width: 72
                    height: Theme.rowHeight
                    radius: Theme.radiusSmall
                    color: cancelMouse.containsMouse ? Theme.surfaceElevated : Theme.surface

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.shown = false
                    }
                }
            }
        }
    }
}
