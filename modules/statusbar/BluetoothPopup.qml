import QtQuick
import "../../themes"
import "../../services" as Services
import "../../components" as Components

Components.Popup {
    id: root

    popupWidth: 330
    padding: Theme.padding
    spacing: Theme.spacing.md

    Connections {
        target: root
        function onShownChanged() {
            Services.Bluetooth.setDiscovering(root.shown);
            if (root.shown)
                Services.Bluetooth.clearError();
        }
    }

    Text {
        width: parent.width
        text: "Bluetooth"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeightBold
    }

    Components.BluetoothPanel {
        width: parent.width
    }
}
