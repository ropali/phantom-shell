import QtQuick
import "../../config" as Config
import "../../themes"

Row {
    id: root
    spacing: Theme.spacing.md

    property var controller: null
    property alias groupSlot: rightGroupSlot

    Item {
        id: rightGroupSlot
        width: childrenRect.width
        height: Config.Settings.barHeight
    }
}
