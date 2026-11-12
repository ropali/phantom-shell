import QtQuick
import QtQuick.Layouts
import "../themes"

Item {
    id: root

    property string title: ""
    property string description: ""
    property string valueText: ""
    property real value: 0
    property real from: 0
    property real to: 1
    property bool isEnabled: true
    signal moved(real value)

    width: parent ? parent.width : 300
    height: content.implicitHeight
    opacity: isEnabled ? 1 : 0.5

    Column {
        id: content
        width: parent.width
        spacing: Theme.spacing.sm

        RowLayout {
            width: parent.width
            spacing: Theme.spacing.md

            Column {
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

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: valueLabel.implicitWidth + Theme.spacing.md * 2
                implicitHeight: 24
                radius: height / 2
                color: Theme.surface
                border.width: Theme.borderWidth
                border.color: Theme.subtleBorder

                Text {
                    id: valueLabel
                    anchors.centerIn: parent
                    text: root.valueText
                    color: Theme.primary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTiny
                    font.weight: Theme.fontWeightBold
                }
            }
        }

        MiniSlider {
            width: parent.width
            value: root.value
            from: root.from
            to: root.to
            isEnabled: root.isEnabled
            onMoved: root.moved(value)
        }
    }
}
