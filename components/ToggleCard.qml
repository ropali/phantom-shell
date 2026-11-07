import QtQuick
import QtQuick.Layouts
import "../themes"

Item {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool emphasis: false
    property bool isEnabled: true
    property bool showChevron: true

    signal toggled()
    signal detailClicked()

    implicitWidth: 170
    implicitHeight: 62
    opacity: isEnabled ? 1 : 0.45
    activeFocusOnTab: isEnabled

    Accessible.role: Accessible.Button
    Accessible.name: title
    Accessible.description: subtitle
    Accessible.onPressAction: if (root.isEnabled) root.toggled()

    Keys.onReturnPressed: if (root.isEnabled) root.toggled()
    Keys.onEnterPressed: if (root.isEnabled) root.toggled()
    Keys.onSpacePressed: if (root.isEnabled) root.toggled()

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: root.emphasis && root.active ? Theme.primary
            : root.active ? Theme.accentSurface
            : cardMouse.containsMouse && root.isEnabled ? Theme.panelSurfaceHover
            : Theme.panelSurface
        border.width: root.activeFocus ? Math.max(2, Theme.borderWidth) : Theme.borderWidth
        border.color: root.activeFocus ? Theme.primary
            : root.active ? (root.emphasis ? Theme.primary : Theme.accentBorder)
            : Theme.subtleBorder

        Behavior on color {
            ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.md + Theme.spacing.xs
        anchors.rightMargin: root.showChevron ? Theme.spacing.sm : Theme.spacing.md
        anchors.topMargin: Theme.spacing.sm
        anchors.bottomMargin: Theme.spacing.sm
        spacing: Theme.spacing.sm

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.icon
            color: root.emphasis && root.active ? Theme.onPrimary
                : root.active ? Theme.primary : Theme.mutedForeground
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSizeMedium
        }

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                width: parent.width
                text: root.title
                color: root.emphasis && root.active ? Theme.onPrimary : Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeBase
                font.weight: Theme.fontWeightBold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                visible: root.subtitle.length > 0
                text: root.subtitle
                color: root.emphasis && root.active
                    ? Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 0.78)
                    : Theme.mutedForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            visible: root.showChevron
            text: "\uf054"
            color: root.emphasis && root.active
                ? Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 0.7)
                : Theme.mutedForeground
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.isEnabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }

    Item {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 28
        visible: root.showChevron

        MouseArea {
            anchors.fill: parent
            enabled: root.isEnabled
            cursorShape: Qt.PointingHandCursor
            onClicked: root.detailClicked()
        }
    }
}
