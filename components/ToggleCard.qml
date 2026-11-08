import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
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
    implicitHeight: 68
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
        radius: Theme.radius
        color: root.emphasis && root.active ? Theme.primary
            : root.active ? Theme.accentSurface
            : cardMouse.containsMouse && root.isEnabled ? Theme.panelSurfaceHover
            : Theme.panelSurface
        border.width: root.activeFocus ? Math.max(2, Theme.borderWidth) : Theme.borderWidth
        border.color: root.activeFocus ? Theme.primary
            : root.active ? (root.emphasis ? Theme.primary : Theme.accentBorder)
            : cardMouse.containsMouse ? Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.5)
            : Theme.subtleBorder

        Behavior on color {
            ColorAnimation { duration: Theme.animationFast; easing.type: Theme.easingType }
        }
        
        Behavior on border.color {
            ColorAnimation { duration: Theme.animationFast }
        }
        
        // Gradient overlay for active state
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: root.active && !root.emphasis ? 0.06 : 0
            visible: root.active
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.primary }
                GradientStop { position: 1.0; color: "transparent" }
            }
            
            Behavior on opacity {
                NumberAnimation { duration: Theme.animationNormal }
            }
        }
        
        // Hover glow
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: cardMouse.containsMouse && !root.active ? 0.04 : 0
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.foreground }
                GradientStop { position: 1.0; color: "transparent" }
            }
            
            Behavior on opacity {
                NumberAnimation { duration: Theme.animationFast }
            }
        }
        
        scale: cardMouse.pressed ? 0.97 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.lg
        anchors.rightMargin: root.showChevron ? Theme.spacing.md : Theme.spacing.lg
        anchors.topMargin: Theme.spacing.md
        anchors.bottomMargin: Theme.spacing.md
        spacing: Theme.spacing.md

        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignVCenter
            radius: Theme.radiusSmall
            color: root.emphasis && root.active 
                ? Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 0.2)
                : root.active 
                    ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2)
                    : Qt.rgba(Theme.mutedForeground.r, Theme.mutedForeground.g, Theme.mutedForeground.b, 0.1)
            
            Behavior on color {
                ColorAnimation { duration: Theme.animationFast }
            }
            
            Text {
                anchors.centerIn: parent
                text: root.icon
                color: root.emphasis && root.active ? Theme.onPrimary
                    : root.active ? Theme.primary : Theme.mutedForeground
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSizeMedium
                
                scale: root.active ? 1.1 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutBack }
                }
            }
        }

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

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

        Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            visible: root.showChevron
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                x: chevronMouse.containsMouse ? parent.width - width + 2 : parent.width - width
                text: "\uf054"
                color: root.emphasis && root.active
                    ? Qt.rgba(Theme.onPrimary.r, Theme.onPrimary.g, Theme.onPrimary.b, 0.7)
                    : Theme.mutedForeground
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSizeSmall
                
                Behavior on x {
                    NumberAnimation { duration: Theme.animationFast }
                }
            }
        }
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        anchors.rightMargin: root.showChevron ? 32 : 0
        hoverEnabled: true
        enabled: root.isEnabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }

    Item {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 32
        visible: root.showChevron

        MouseArea {
            id: chevronMouse
            anchors.fill: parent
            enabled: root.isEnabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.detailClicked()
        }
    }
}
