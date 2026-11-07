import QtQuick
import QtQuick.Controls
import Quickshell
import "../../themes"
import "../../config" as Config
import "../../services" as Services

PopupWindow {
    id: root

    required property Item anchorItem
    property var menuHandle: null
    property bool shown: false

    readonly property bool above: Config.Settings.barPosition === "bottom"
    readonly property int maxMenuHeight: 420

    function openMenu(handle) {
        if (!handle)
            return;
        Services.UiState.dismissAll();
        root.menuHandle = handle;
        root.shown = true;
    }

    function closeMenu() {
        root.shown = false;
    }

    function toggleMenu(handle) {
        if (root.shown)
            root.closeMenu();
        else
            root.openMenu(handle);
    }

    visible: shown
    color: "transparent"
    grabFocus: false
    implicitWidth: 260
    implicitHeight: Math.min(stack.currentItem ? stack.currentItem.implicitHeight : 0, maxMenuHeight)
        + Theme.padding * 2

    anchor.item: root.anchorItem
    anchor.edges: root.above ? Edges.Top : Edges.Bottom
    anchor.gravity: root.above ? Edges.Top : Edges.Bottom
    anchor.adjustment: PopupAdjustment.SlideX
    anchor.margins.top: root.above ? 0 : 6
    anchor.margins.bottom: root.above ? 6 : 0

    Component.onDestruction: {
        if (root.shown)
            Services.UiState.popupClosed();
    }

    onClosed: root.shown = false
    onShownChanged: {
        if (root.shown) {
            Services.UiState.popupOpened();
            stack.clear();
            if (root.menuHandle)
                stack.push(pageComponent, { handle: root.menuHandle, showBack: false });
        } else {
            Services.UiState.popupClosed();
            stack.clear();
        }
    }

    Connections {
        target: Services.UiState
        function onDismissRequested() {
            root.closeMenu();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.popupBackground
        border.width: Theme.borderWidth
        border.color: Theme.border

        StackView {
            id: stack
            anchors.fill: parent
            anchors.margins: Theme.padding
        }
    }

    Component {
        id: pageComponent

        TrayMenuPage {
            onOpenSubmenu: (entry) => stack.push(pageComponent, { handle: entry, showBack: true })
            onActivate: (entry) => {
                if (entry && entry.enabled)
                    entry.triggered();
                root.closeMenu();
            }
            onBack: stack.pop()
        }
    }
}
