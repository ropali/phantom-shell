import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../themes"
import "../../config" as Config
import "../../services" as Services
import "../../components" as Components

PanelWindow {
    id: root

    readonly property var categories: [
        { id: "panel", title: "Panel", icon: "\uf0c9", description: "Status bar layout and modules", page: "pages/PanelSettings.qml" },
        { id: "appearance", title: "Appearance", icon: "\uf1fc", description: "Theme, typography and effects", page: "pages/AppearanceSettings.qml" },
        { id: "datetime", title: "Date & Time", icon: "\uf017", description: "Clock and date formats", page: "pages/DateTimeSettings.qml" },
        { id: "calendar", title: "Calendar", icon: "\uf073", description: "Calendar flyout behavior", page: "pages/CalendarSettings.qml" },
        { id: "controlcenter", title: "Control Center", icon: "\uf1de", description: "Quick settings dashboard", page: "pages/ControlCenterSettings.qml" },
        { id: "launcher", title: "Launcher", icon: "\uf135", description: "Application launcher", page: "pages/LauncherSettings.qml" },
        { id: "notifications", title: "Notifications", icon: "\uf0f3", description: "Popups and notification center", page: "pages/NotificationSettings.qml" },
        { id: "wallpaper", title: "Wallpaper", icon: "\uf03e", description: "Wallpaper source and scaling", page: "pages/WallpaperSettings.qml" },
        { id: "shortcuts", title: "Keyboard Shortcuts", icon: "\uf11c", description: "Global and internal shortcuts", page: "pages/ShortcutSettings.qml" },
        { id: "advanced", title: "Advanced", icon: "\uf085", description: "Diagnostics and reset tools", page: "pages/AdvancedSettings.qml" }
    ]

    property var targetScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    property bool alive: false
    property real reveal: 0
    property string currentCategory: "panel"

    anchors.left: true
    anchors.right: true
    anchors.top: true
    anchors.bottom: true

    screen: root.targetScreen
    visible: root.alive
    color: "transparent"
    aboveWindows: true
    focusable: true
    exclusiveZone: -1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "phantom-settings"
    WlrLayershell.keyboardFocus: root.alive
        ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    function categoryPage(id) {
        for (let i = 0; i < categories.length; i++) {
            if (categories[i].id === id)
                return categories[i].page;
        }
        return categories[0].page;
    }

    function applyMonitor(output) {
        try {
            const data = JSON.parse(output);
            if (!data || typeof data.monitor !== "string")
                return;
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === data.monitor) {
                    root.targetScreen = Quickshell.screens[i];
                    return;
                }
            }
        } catch (error) {
            console.warn("Failed to resolve focused monitor:", error);
        }
    }

    function resolveFocusedScreen() {
        if (Quickshell.screens.length === 0)
            return;
        if (!root.targetScreen)
            root.targetScreen = Quickshell.screens[0];
        if (!focusProcess.running)
            focusProcess.running = true;
    }

    Process {
        id: focusProcess
        command: ["hyprctl", "activeworkspace", "-j"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.applyMonitor(text)
        }
    }

    Timer {
        id: closeTimer
        interval: Math.max(1, Theme.animationNormal)
        repeat: false
        onTriggered: root.alive = false
    }

    Connections {
        target: Services.UiState
        function onSettingsOpenChanged() {
            if (Services.UiState.settingsOpen) {
                closeTimer.stop();
                root.resolveFocusedScreen();
                root.alive = true;
                root.reveal = 1;
                Qt.callLater(() => keyCatcher.forceActiveFocus());
            } else {
                root.reveal = 0;
                closeTimer.restart();
            }
        }
    }

    Behavior on reveal {
        NumberAnimation {
            duration: Config.Settings.animationsEnabled ? Theme.animationNormal : 0
            easing.type: Theme.easingType
        }
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.alive
        onActivated: Services.UiState.closeSettings()
    }

    onClosed: Services.UiState.closeSettings()

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.5 * root.reveal)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Services.UiState.closeSettings()
    }

    Rectangle {
        anchors.fill: card
        anchors.margins: -10
        radius: card.radius + 10
        color: Qt.rgba(0, 0, 0, 0.28)
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(Config.Settings.settingsWidth, root.width - Theme.spacing.xl * 2)
        height: Math.min(Config.Settings.settingsHeight, root.height - Theme.spacing.xl * 2)
        radius: Theme.radiusLarge
        color: Theme.popupBackground
        border.width: Theme.borderWidth
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.28)
        opacity: root.reveal
        scale: 0.97 + 0.03 * root.reveal

        Behavior on opacity {
            NumberAnimation { duration: Config.Settings.animationsEnabled ? Theme.animationNormal : 0 }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Config.Settings.animationsEnabled ? Theme.animationNormal : 0
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => mouse.accepted = true
        }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.045)
                }
                GradientStop { position: 0.52; color: "transparent" }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.035)
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: Theme.radiusLarge
            anchors.rightMargin: Theme.radiusLarge
            height: 1
            color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.06)
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            spacing: Theme.spacing.lg

            SettingsSidebar {
                id: sidebar
                Layout.preferredWidth: Math.max(210,
                    card.width * Config.Settings.settingsSidebarPercent / 100)
                Layout.fillHeight: true
                categories: root.categories
                currentId: root.currentCategory
                onSelected: (id) => root.currentCategory = id
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: Theme.borderWidth
                color: Theme.subtleBorder
            }

            Item {
                id: content
                Layout.fillWidth: true
                Layout.fillHeight: true

                SettingsContent {
                    anchors.fill: parent
                    pageSource: root.categoryPage(root.currentCategory)
                }

                Components.IconButton {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    icon: "\uf00d"
                    tooltip: "Close settings"
                    onClicked: Services.UiState.closeSettings()
                }
            }
        }
    }

    Item {
        id: keyCatcher
        anchors.fill: parent
        focus: root.alive
        Keys.onEscapePressed: Services.UiState.closeSettings()
    }
}
