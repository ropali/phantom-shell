import QtQuick
import "../../themes"
import "../../services" as Services
import "../../components" as Components

Components.Popup {
    id: root

    popupWidth: 330
    padding: Theme.padding
    spacing: Theme.spacing.md

    signal passwordRequired(var network)

    Connections {
        target: root
        function onShownChanged() {
            Services.Network.setScanning(root.shown);
            if (root.shown)
                Services.Network.clearError();
        }
    }

    Text {
        width: parent.width
        text: "Network"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeightBold
    }

    Components.NetworkPanel {
        width: parent.width
        onPasswordRequired: (network) => root.passwordRequired(network)
    }
}
