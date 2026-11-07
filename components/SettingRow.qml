import QtQuick
import QtQuick.Layouts
import "../themes"

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string trailing: ""
    property bool active: false
    property bool isEnabled: true
    signal clicked()

    width: parent ? parent.width : 300
    height: Theme.rowHeight
    opacity: enabled ? 1 : 0.45

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: rowMouse.containsMouse && root.enabled ? Theme.surface : "transparent"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.sm
        anchors.rightMargin: Theme.spacing.sm
        spacing: Theme.spacing.sm

        Text {
            Layout.fillWidth: true
            text: root.title
            color: root.active ? Theme.primary : Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBase
            font.weight: root.active ? Theme.fontWeightBold : Theme.fontWeightNormal
            elide: Text.ElideRight
        }

        Text {
            visible: root.subtitle.length > 0
            text: root.subtitle
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            elide: Text.ElideRight
            Layout.maximumWidth: 120
        }

        Text {
            visible: root.trailing.length > 0
            text: root.trailing
            color: root.active ? Theme.primary : Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
        }

        Text {
            visible: root.active
            text: "\uf00c"
            color: Theme.primary
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.isEnabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
