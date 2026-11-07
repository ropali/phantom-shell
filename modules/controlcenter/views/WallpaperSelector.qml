import QtQuick
import "../../../themes"
import "../../../services" as Services
import "../../../components" as Components

Flickable {
    id: root

    readonly property int preferredHeight: content.implicitHeight

    anchors.fill: parent
    contentWidth: width
    contentHeight: content.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height

    Column {
        id: content
        width: root.width
        spacing: Theme.spacing.md

        Rectangle {
            width: parent.width
            height: 150
            radius: Theme.radiusSmall
            color: Theme.surface
            border.width: Theme.borderWidth
            border.color: Theme.border

            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: Services.Wallpapers.currentPath.length > 0
                    ? "file://" + Services.Wallpapers.currentPath : ""
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
            }
        }

        Text {
            width: parent.width
            text: Services.Wallpapers.name(Services.Wallpapers.currentPath) || "No wallpaper selected"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBase
            elide: Text.ElideLeft
        }

        Components.WallpaperPicker {
            width: parent.width
            height: 220
        }

        Text {
            width: parent.width
            visible: Services.Wallpapers.files.length === 0
            text: "No wallpapers found in ~/Pictures/wallpapers"
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
