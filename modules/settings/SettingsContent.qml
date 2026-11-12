import QtQuick
import "../../themes"

Item {
    id: root

    property string pageSource: ""

    Loader {
        id: loader
        anchors.fill: parent
        source: root.pageSource
        opacity: 0
        scale: 0.985

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animationNormal
                easing.type: Theme.easingType
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.animationNormal
                easing.type: Easing.OutCubic
            }
        }

        onSourceChanged: {
            opacity = 0;
            scale = 0.985;
        }

        onLoaded: {
            opacity = 1;
            scale = 1;
        }
    }
}
