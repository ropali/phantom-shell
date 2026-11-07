import QtQuick
import QtQuick.Layouts
import "../themes"

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool isEnabled: true

    signal toggled()

    width: parent ? parent.width : 300
    height: 44
    opacity: isEnabled ? 1 : 0.45

    Accessible.role: Accessible.CheckBox
    Accessible.name: title
    Accessible.description: subtitle
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.onPressAction: if (root.isEnabled) root.toggled()

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: rowMouse.containsMouse && root.isEnabled ? Theme.surface : "transparent"
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.isEnabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.md + Theme.spacing.xs
        anchors.rightMargin: Theme.spacing.md
        spacing: Theme.spacing.md

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                width: parent.width
                text: root.title
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBase
                font.weight: Theme.fontWeightBold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: Theme.mutedForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }
        }

        ToggleSwitch {
            Layout.alignment: Qt.AlignVCenter
            checked: root.checked
            enabled: root.isEnabled
            onToggled: root.toggled()
        }
    }
}
