import QtQuick
import Quickshell
import "../config" as Config
import "../themes"

PopupWindow {
    id: root

    property Item anchorItem: null
    property string text: ""
    property bool shown: false
    property bool above: Config.Settings.barPosition === "bottom"

    visible: shown && text.length > 0
    color: "transparent"
    implicitWidth: label.implicitWidth + 18
    implicitHeight: label.implicitHeight + 10
    grabFocus: false

    anchor.item: root.anchorItem
    anchor.edges: root.above ? Edges.Top : Edges.Bottom
    anchor.gravity: root.above ? Edges.Top : Edges.Bottom
    anchor.adjustment: PopupAdjustment.SlideX
    anchor.margins.top: root.above ? 0 : 6
    anchor.margins.bottom: root.above ? 6 : 0

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: Theme.popupBackground
        border.width: Theme.borderWidth
        border.color: Theme.border
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBase
    }
}
