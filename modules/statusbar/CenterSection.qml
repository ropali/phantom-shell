import QtQuick
import "../../config" as Config

Item {
    implicitWidth: indicator.implicitWidth
    implicitHeight: Config.Settings.barHeight

    WorkspaceIndicator {
        id: indicator
        anchors.centerIn: parent
    }
}
