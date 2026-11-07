import QtQuick
import "../themes"
import "../services" as Services

Item {
    id: root

    width: parent ? parent.width : 300
    implicitHeight: 160

    GridView {
        id: grid
        anchors.fill: parent
        cellWidth: 64
        cellHeight: 48
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: Services.Wallpapers.files

        delegate: Item {
            required property var modelData

            width: grid.cellWidth
            height: grid.cellHeight

            readonly property bool current: Services.Wallpapers.currentPath === modelData

            Rectangle {
                anchors.centerIn: parent
                width: 58
                height: 42
                radius: 3
                color: Theme.surfaceElevated
                border.width: current ? 2 : Theme.borderWidth
                border.color: current ? Theme.primary : Theme.border

                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: "file://" + modelData
                    sourceSize.width: 56
                    sourceSize.height: 40
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.Wallpapers.setWallpaper(modelData)
            }
        }
    }
}
