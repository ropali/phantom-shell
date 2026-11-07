pragma Singleton
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: service

    readonly property var players: Mpris.players

    readonly property var player: {
        const list = players ? players.values : [];
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].trackTitle && list[i].isPlaying)
                return list[i];
        }
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].trackTitle)
                return list[i];
        }
        return null;
    }

    readonly property bool available: player !== null
    readonly property bool playing: player ? player.isPlaying : false
    readonly property string title: player ? (player.trackTitle || "") : ""
    readonly property string artist: player ? (player.trackArtist || "") : ""
    readonly property string album: player ? (player.trackAlbum || "") : ""
    readonly property string artUrl: player ? (player.trackArtUrl || "") : ""
    readonly property real position: player ? player.position : 0
    readonly property real length: player ? player.length : 0
    readonly property real progress: length > 0 ? Math.max(0, Math.min(1, position / length)) : 0

    function togglePlaying() {
        if (player && player.canTogglePlaying)
            player.togglePlaying();
    }

    function next() {
        if (player && player.canGoNext)
            player.next();
    }

    function previous() {
        if (player && player.canGoPrevious)
            player.previous();
    }
}
