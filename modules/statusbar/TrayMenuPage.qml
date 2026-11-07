import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../themes"

Flickable {
    id: page

    required property var handle
    property bool showBack: false

    signal openSubmenu(var entry)
    signal activate(var entry)
    signal back()

    readonly property var menuEntries: opener.children

    implicitWidth: 240
    implicitHeight: Math.min(contentHeight, 420)
    contentWidth: width
    contentHeight: column.height
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height

    QsMenuOpener {
        id: opener
        menu: page.handle
    }

    Column {
        id: column
        width: page.width
        spacing: 2

        Rectangle {
            id: backRow
            visible: page.showBack
            width: parent.width
            height: visible ? Theme.controlHeight : 0
            radius: Theme.radiusSmall
            color: backMouse.containsMouse ? Theme.surface : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.sm
                anchors.rightMargin: Theme.spacing.sm
                spacing: Theme.spacing.sm

                Text {
                    text: "\uf060"
                    color: Theme.mutedForeground
                    font.family: Theme.iconFontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }

                Text {
                    Layout.fillWidth: true
                    text: "Back"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeBase
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: page.back()
            }
        }

        Repeater {
            model: page.menuEntries

            delegate: Item {
                id: entryRow
                required property var modelData

                readonly property bool separator: modelData.isSeparator
                readonly property bool submenu: modelData.hasChildren

                width: column.width
                height: separator ? 9 : Theme.controlHeight

                Rectangle {
                    visible: entryRow.separator
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Theme.spacing.sm
                    anchors.rightMargin: Theme.spacing.sm
                    height: 1
                    color: Theme.border
                }

                Rectangle {
                    visible: !entryRow.separator
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    color: entryMouse.containsMouse && entryRow.modelData.enabled
                        ? Theme.surface : "transparent"
                }

                RowLayout {
                    visible: !entryRow.separator
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.sm
                    anchors.rightMargin: Theme.spacing.sm
                    spacing: Theme.spacing.sm

                    Text {
                        visible: entryRow.modelData.buttonType !== QsMenuButtonType.None
                        text: entryRow.modelData.checkState === Qt.Checked ? "\uf00c" : " "
                        color: Theme.primary
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        Layout.preferredWidth: visible ? 16 : 0
                        Layout.alignment: Qt.AlignVCenter
                    }

                    IconImage {
                        visible: entryRow.modelData.icon !== ""
                        source: entryRow.modelData.icon
                        implicitSize: 16
                        Layout.preferredWidth: visible ? 16 : 0
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: entryRow.modelData.text
                        color: entryRow.modelData.enabled ? Theme.foreground : Theme.mutedForeground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        visible: entryRow.submenu
                        text: "\uf054"
                        color: Theme.mutedForeground
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        Layout.preferredWidth: visible ? 12 : 0
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: entryMouse
                    anchors.fill: parent
                    enabled: !entryRow.separator && entryRow.modelData.enabled
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (entryRow.submenu)
                            page.openSubmenu(entryRow.modelData);
                        else
                            page.activate(entryRow.modelData);
                    }
                }
            }
        }
    }
}
