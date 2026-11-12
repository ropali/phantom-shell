import QtQuick
import "../themes"

Item {
    id: root

    property string value: ""
    property string placeholder: ""
    property string leadingIcon: ""
    property bool isEnabled: true
    signal edited(string text)

    readonly property real leadingSpace: leadingIcon.length > 0
        ? Theme.spacing.xl + Theme.spacing.sm : 0

    width: parent ? parent.width : 200
    height: Theme.controlHeight + 4
    opacity: isEnabled ? 1 : 0.5

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSmall
        color: input.activeFocus
            ? Qt.rgba(Theme.surfaceElevated.r, Theme.surfaceElevated.g, Theme.surfaceElevated.b, 0.8)
            : Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.7)
        border.width: input.activeFocus ? 2 : Theme.borderWidth
        border.color: input.activeFocus ? Theme.primary : Theme.subtleBorder

        Behavior on border.color {
            ColorAnimation { duration: Theme.animationFast }
        }

        Behavior on color {
            ColorAnimation { duration: Theme.animationFast }
        }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.md
        anchors.verticalCenter: parent.verticalCenter
        visible: root.leadingIcon.length > 0
        text: root.leadingIcon
        color: input.activeFocus ? Theme.primary : Theme.mutedForeground
        font.family: Theme.iconFontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.md + root.leadingSpace
        anchors.rightMargin: Theme.spacing.md
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.foreground
        selectionColor: Theme.primary
        selectedTextColor: Theme.onPrimary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBase
        clip: true
        enabled: root.isEnabled
        text: root.value
        onTextChanged: if (activeFocus) root.edited(text)
        onEditingFinished: root.edited(text)
    }

    Text {
        anchors.left: input.left
        anchors.right: input.right
        anchors.verticalCenter: parent.verticalCenter
        visible: input.text.length === 0
        text: root.placeholder
        color: Theme.mutedForeground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBase
        elide: Text.ElideRight
    }

    onValueChanged: {
        if (input.text !== value)
            input.text = value;
    }
}
