import QtQuick
import QtQuick.Layouts
import "../themes"

Item {
    id: root

    property string icon: ""
    property string title: ""
    property string detail: ""
    property string valueText: ""
    property real value: 0
    property real from: 0
    property real to: 1
    property bool isEnabled: true
    property bool showDetail: false

    signal moved(real value)
    signal detailClicked()

    width: parent ? parent.width : 300
    implicitHeight: Theme.spacing.xl + Theme.spacing.sm
    height: implicitHeight
    opacity: isEnabled ? 1 : 0.45

    Accessible.role: Accessible.Slider
    Accessible.name: title
    Accessible.description: valueText

    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacing.sm

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.icon
            color: Theme.mutedForeground
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSizeMedium
        }

        MiniSlider {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            value: root.value
            from: root.from
            to: root.to
            isEnabled: root.isEnabled
            onMoved: (value) => root.moved(value)
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 120
            visible: root.detail.length > 0
            text: root.detail
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            elide: Text.ElideRight
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.valueText
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        Item {
            width: 12
            height: parent.height
            visible: root.showDetail

            Text {
                anchors.centerIn: parent
                text: "\uf054"
                color: detailMouse.containsMouse ? Theme.primary : Theme.mutedForeground
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            MouseArea {
                id: detailMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.detailClicked()
            }
        }
    }
}
