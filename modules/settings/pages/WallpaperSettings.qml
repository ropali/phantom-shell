import QtQuick
import QtQuick.Layouts
import "../../../themes"
import "../../../config" as Config
import "../../../components" as Components
import "../../../services" as Services

Components.SettingsPage {
    title: "Wallpaper"
    icon: "\uf03e"
    description: "Choose a wallpaper and configure how it is displayed."

    Components.SettingsCard {
        title: "Current wallpaper"

        Rectangle {
            width: parent.width
            height: 150
            radius: Theme.radiusSmall
            color: Theme.surface
            border.width: Theme.borderWidth
            border.color: Theme.border

            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: Services.Wallpapers.currentPath.length > 0
                    ? "file://" + Services.Wallpapers.currentPath : ""
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
            }
        }

        Text {
            width: parent.width
            text: Services.Wallpapers.name(Services.Wallpapers.currentPath) || "No wallpaper selected"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeBase
            elide: Text.ElideLeft
        }

        Components.WallpaperPicker {
            width: parent.width
            height: 200
        }
    }

    Components.SettingsCard {
        title: "Source"

        Components.SettingsTextField {
            value: Config.Settings.wallpaperDirectory
            placeholder: "Wallpaper directory"
            onEdited: (text) => {
                Config.Settings.wallpaperDirectory = text;
                Config.Settings.scheduleSave();
                Services.Wallpapers.refresh();
            }
        }

        Components.SettingsChoiceRow {
            title: "Scaling"
            options: [
                { id: "crop", label: "Crop" },
                { id: "fit", label: "Fit" },
                { id: "stretch", label: "Stretch" },
                { id: "center", label: "Center" }
            ]
            current: Config.Settings.wallpaperScaling
            onSelected: (id) => {
                Config.Settings.wallpaperScaling = id;
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsSliderRow {
            title: "Transition duration"
            description: "Fade time when the wallpaper changes."
            valueText: Config.Settings.wallpaperTransition + " ms"
            value: Config.Settings.wallpaperTransition
            from: 0
            to: 1000
            onMoved: (value) => {
                Config.Settings.wallpaperTransition = Math.round(value);
                Config.Settings.scheduleSave();
            }
        }

        Components.SettingsButton {
            text: "Shuffle wallpaper"
            icon: "\uf074"
            onClicked: {
                if (Services.Wallpapers.files.length === 0)
                    return;
                const index = Math.floor(Math.random() * Services.Wallpapers.files.length);
                Services.Wallpapers.setWallpaper(Services.Wallpapers.files[index]);
            }
        }

        Components.SettingsButton {
            text: "Reset wallpaper settings"
            icon: "\uf2ea"
            onClicked: Config.Settings.resetWallpaper()
        }
    }
}
