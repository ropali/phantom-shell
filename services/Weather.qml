pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config" as Config

Singleton {
    id: service

    readonly property string query: Config.Settings.weatherLocation.trim().length > 0
        ? encodeURIComponent(Config.Settings.weatherLocation.trim()) : ""

    property bool available: false
    property string location: ""
    property string condition: ""
    property int temperature: 0
    property int humidity: 0
    property string icon: "\uf185"
    property string lastError: ""

    Process {
        id: fetchProcess
        running: false
        command: ["sh", "-c",
            "curl -fsSL --max-time 10 'https://wttr.in/"
            + service.query + "?format=j1'"]

        stdout: StdioCollector {
            onStreamFinished: service.parse(text)
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                service.lastError = "Weather update failed";
        }
    }

    Timer {
        interval: 1800000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: service.refresh()
    }

    function refresh() {
        if (!fetchProcess.running)
            fetchProcess.running = true;
    }

    function iconFor(code, description) {
        const value = parseInt(code, 10);
        const text = (description || "").toLowerCase();

        if (value === 113)
            return "\uf185";
        if (value === 116)
            return "\uf6c4";
        if (value === 119 || value === 122)
            return "\uf0c2";
        if (value === 143 || value === 248 || value === 260)
            return "\uf72e";
        if ([200, 386, 389, 392, 395].indexOf(value) >= 0
            || text.indexOf("thunder") >= 0)
            return "\uf0e7";
        if ([179, 182, 185, 227, 230, 317, 320, 323, 326, 329, 332,
             335, 338, 368, 371].indexOf(value) >= 0
            || text.indexOf("snow") >= 0 || text.indexOf("sleet") >= 0)
            return "\uf2dc";
        if (text.indexOf("rain") >= 0 || text.indexOf("drizzle") >= 0
            || text.indexOf("shower") >= 0)
            return "\uf73d";
        return "\uf0c2";
    }

    function parse(output) {
        try {
            const data = JSON.parse(output);
            const current = data.current_condition && data.current_condition[0];
            const area = data.nearest_area && data.nearest_area[0];
            if (!current)
                return;

            const description = current.weatherDesc && current.weatherDesc[0]
                ? current.weatherDesc[0].value : "";
            const areaName = area && area.areaName && area.areaName[0]
                ? area.areaName[0].value : "";
            const country = area && area.country && area.country[0]
                ? area.country[0].value : "";

            temperature = parseInt(current.temp_C, 10);
            humidity = parseInt(current.humidity, 10);
            condition = description;
            location = areaName + (country ? ", " + country : "");
            icon = iconFor(current.weatherCode, description);
            available = true;
            lastError = "";
        } catch (error) {
            lastError = "Weather parse failed";
        }
    }
}
