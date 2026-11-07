import QtQuick
import QtQuick.Layouts
import "../../themes"
import "../../services" as Services

import "../../components" as Components

Components.Popup {
    id: root

    popupWidth: 320
    padding: Theme.padding
    spacing: Theme.spacing.md

    function setVolumeFromX(x) {
        Services.Audio.setVolume(Math.max(0, Math.min(1, x / volumeSlider.width)));
    }

    Text {
        width: parent.width
        text: "Audio"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeightBold
    }

    RowLayout {
        width: parent.width
        spacing: Theme.spacing.md

        Item {
            implicitWidth: Theme.fontSizeLarge
            implicitHeight: Theme.fontSizeLarge

            Text {
                anchors.centerIn: parent
                text: Services.Audio.muted ? "\uf026" : (Services.Audio.volume > 0.5 ? "\uf028" : "\uf027")
                color: Services.Audio.muted ? Theme.mutedForeground : Theme.foreground
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.Audio.toggleMute()
            }
        }

        Text {
            Layout.fillWidth: true
            text: "Output volume"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBase
        }

        Text {
            text: Services.Audio.sink
                ? (Services.Audio.muted ? "Muted" : Services.Audio.volumePercent + "%")
                : "No device"
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    Item {
        id: volumeSlider
        width: parent.width
        height: Theme.spacing.xl

        readonly property real value: Math.max(0, Math.min(1, Services.Audio.volume))

        Rectangle {
            id: volumeTrack
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: Theme.spacing.sm
            radius: Theme.spacing.xs
            color: Theme.surfaceElevated
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: volumeTrack.width * volumeSlider.value
            height: Theme.spacing.sm
            radius: Theme.spacing.xs
            color: Theme.primary
        }

        Rectangle {
            width: Theme.spacing.lg
            height: Theme.spacing.lg
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(volumeSlider.width - width, volumeSlider.width * volumeSlider.value - width / 2))
            color: Theme.foreground
        }

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => root.setVolumeFromX(mouse.x)
            onPositionChanged: (mouse) => {
                if (pressed)
                    root.setVolumeFromX(mouse.x);
            }
        }
    }

    Rectangle {
        width: parent.width
        height: Theme.borderWidth
        color: Theme.border
    }

    Text {
        width: parent.width
        text: "Output device"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeBase
        font.weight: Theme.fontWeightBold
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.xs

        Repeater {
            model: Services.Audio.sinks

            delegate: Rectangle {
                id: sinkRow
                required property var modelData

                readonly property bool active: Services.Audio.isDefaultSink(modelData)

                width: root.popupWidth - root.padding * 2
                height: Theme.rowHeight
                radius: Theme.radiusSmall
                color: active ? Theme.surface
                    : sinkMouse.containsMouse ? Theme.surface : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.md
                    anchors.rightMargin: Theme.spacing.md
                    spacing: Theme.spacing.md

                    Text {
                        Layout.fillWidth: true
                        text: sinkRow.modelData.description || sinkRow.modelData.nickname || sinkRow.modelData.name
                        elide: Text.ElideRight
                        color: sinkRow.active ? Theme.primary : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase
                    }

                    Text {
                        visible: sinkRow.active
                        text: "\uf00c"
                        color: Theme.primary
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                MouseArea {
                    id: sinkMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Audio.setDefaultSink(sinkRow.modelData)
                }
            }
        }

        Text {
            width: parent.width
            visible: Services.Audio.sinks.length === 0
            text: "No output devices found"
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    Rectangle {
        width: parent.width
        height: Theme.borderWidth
        color: Theme.border
    }

    RowLayout {
        width: parent.width
        spacing: Theme.spacing.md

        Item {
            implicitWidth: Theme.fontSizeLarge
            implicitHeight: Theme.fontSizeLarge

            Text {
                anchors.centerIn: parent
                text: Services.Audio.sourceMuted ? "\uf131" : "\uf130"
                color: Services.Audio.sourceMuted ? Theme.mutedForeground : Theme.foreground
                font.family: Theme.iconFontFamily
                font.pixelSize: Theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Services.Audio.toggleSourceMute()
            }
        }

        Text {
            Layout.fillWidth: true
            text: "Input device"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBase
            font.weight: Theme.fontWeightBold
        }

        Text {
            text: Services.Audio.sourceMuted ? "Muted" : ""
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    Column {
        width: parent.width
        spacing: Theme.spacing.xs

        Repeater {
            model: Services.Audio.sources

            delegate: Rectangle {
                id: sourceRow
                required property var modelData

                readonly property bool active: Services.Audio.isDefaultSource(modelData)

                width: root.popupWidth - root.padding * 2
                height: Theme.rowHeight
                radius: Theme.radiusSmall
                color: active ? Theme.surface
                    : sourceMouse.containsMouse ? Theme.surface : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.md
                    anchors.rightMargin: Theme.spacing.md
                    spacing: Theme.spacing.md

                    Text {
                        Layout.fillWidth: true
                        text: sourceRow.modelData.description || sourceRow.modelData.nickname || sourceRow.modelData.name
                        elide: Text.ElideRight
                        color: sourceRow.active ? Theme.primary : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeBase
                    }

                    Text {
                        visible: sourceRow.active
                        text: "\uf00c"
                        color: Theme.primary
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                MouseArea {
                    id: sourceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Audio.setDefaultSource(sourceRow.modelData)
                }
            }
        }

        Text {
            width: parent.width
            visible: Services.Audio.sources.length === 0
            text: "No input devices found"
            color: Theme.mutedForeground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
