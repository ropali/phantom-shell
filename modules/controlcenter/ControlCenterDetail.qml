import QtQuick
import QtQuick.Layouts
import "views"
import "../../themes"

Item {
    id: root

    property string viewId: ""

    readonly property int maximumHeight: 650

    readonly property int preferredHeight: {
        const view = loader.item;
        const contentHeight = view && view.preferredHeight !== undefined
            ? view.preferredHeight
            : root.maximumHeight;
        const chrome = header.height + Theme.spacing.md + Theme.spacing.sm;
        return Math.max(chrome, Math.min(contentHeight + chrome, root.maximumHeight));
    }

    signal back()
    signal passwordRequired(var network)

    focus: root.viewId.length > 0
    Keys.onEscapePressed: root.back()

    function titleFor(id) {
        if (id === "wifi") return "Wi-Fi";
        if (id === "bluetooth") return "Bluetooth";
        if (id === "audio") return "Audio";
        if (id === "theme") return "Theme";
        if (id === "wallpaper") return "Wallpaper";
        if (id === "power") return "Power profile";
        if (id === "battery") return "Battery";
        if (id === "nightlight") return "Night light";
        if (id === "dnd") return "Do Not Disturb";
        if (id === "bar") return "Status bar";
        return "";
    }

    function componentFor(id) {
        if (id === "wifi") return wifiView;
        if (id === "bluetooth") return bluetoothView;
        if (id === "audio") return audioView;
        if (id === "theme") return themeView;
        if (id === "wallpaper") return wallpaperView;
        if (id === "power") return powerView;
        if (id === "battery") return batteryView;
        if (id === "nightlight") return nightLightView;
        if (id === "dnd") return dndView;
        if (id === "bar") return barView;
        return null;
    }

    RowLayout {
        id: header
        width: parent.width
        height: 28
        spacing: Theme.spacing.sm

        Item {
            width: 24
            height: 24

            Text {
                anchors.centerIn: parent
                text: "\uf060"
                color: backMouse.containsMouse ? Theme.primary : Theme.mutedForeground
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.back()
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.titleFor(root.viewId)
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeightBold
        }
    }

    Loader {
        id: loader
        anchors.top: header.bottom
        anchors.topMargin: Theme.spacing.md
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        sourceComponent: root.componentFor(root.viewId)
    }

    Component {
        id: wifiView
        WifiView {
            onPasswordRequired: (network) => root.passwordRequired(network)
        }
    }

    Component { id: bluetoothView; BluetoothView {} }
    Component { id: audioView; AudioView {} }
    Component { id: themeView; ThemeSelector {} }
    Component { id: wallpaperView; WallpaperSelector {} }
    Component { id: powerView; PowerProfileView {} }
    Component { id: batteryView; BatteryView {} }
    Component { id: nightLightView; NightLightView {} }
    Component { id: dndView; DndView {} }
    Component { id: barView; StatusBarView {} }
}
