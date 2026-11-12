import QtQuick
import QtQuick.Layouts
import "../themes"

Item {
    id: root

    property string title: ""
    property string description: ""
    property bool checked: false
    property bool isEnabled: true
    signal toggled()

    width: parent ? parent.width : 300
    height: Math.max(Theme.rowHeight, textColumn.implicitHeight + Theme.spacing.md)
    opacity: isEnabled ? 1 : 0.5

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.sm
        anchors.rightMargin: Theme.spacing.sm
        spacing: Theme.spacing.md

        Column {
            id: textColumn
            Layout.fillWidth: true
            spacing: 2

            Text {
                width: parent.width
                text: root.title
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBase
                font.weight: Theme.fontWeightMedium
            }

            Text {
                width: parent.width
                visible: root.description.length > 0
                text: root.description
                color: Theme.mutedForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                lineHeight: Theme.lineHeight
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
