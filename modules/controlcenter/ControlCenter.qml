import QtQuick
import QtQuick.Layouts
import "../../themes"
import "../../config" as Config
import "../../services" as Services
import "../../components" as Components

Components.Popup {
    id: root

    popupWidth: 440
    padding: Theme.padding
    spacing: 0
    alignRight: Config.Settings.barStyle === "pills"
        || Config.Settings.barControlCenterPosition === "right"

    property string detailId: ""
    property bool reanchoring: false

    signal passwordRequired(var network)
    signal powerRequested()

    onDetailIdChanged: Services.UiState.detailOpen = root.detailId.length > 0

    Component.onDestruction: {
        if (root.detailId.length > 0)
            Services.UiState.detailOpen = false;
    }

    Connections {
        target: Services.UiState
        function onDetailCloseRequested() {
            root.detailId = "";
        }
    }

    Connections {
        target: root

        function onShownChanged() {
            if (root.shown) {
                if (!root.reanchoring)
                    root.detailId = "";
                Services.Network.setScanning(true);
                Services.Bluetooth.setDiscovering(true);
                Services.Network.clearError();
                Services.Bluetooth.clearError();
                Services.Brightness.refresh();
                Services.Wallpapers.refresh();
            } else {
                if (!root.reanchoring)
                    root.detailId = "";
                Services.Network.setScanning(false);
                Services.Bluetooth.setDiscovering(false);
            }
        }
    }

    Item {
        width: parent.width
        height: root.detailId.length > 0 ? detail.preferredHeight : overview.implicitHeight

        StackLayout {
            anchors.fill: parent
            currentIndex: root.detailId.length > 0 ? 1 : 0

            ControlCenterOverview {
                id: overview
                onOpenDetail: (id) => root.detailId = id
                onPowerRequested: root.powerRequested()
                onCloseRequested: root.shown = false
            }

            ControlCenterDetail {
                id: detail
                viewId: root.detailId
                onBack: root.detailId = ""
                onPasswordRequired: (network) => root.passwordRequired(network)
            }
        }
    }
}
