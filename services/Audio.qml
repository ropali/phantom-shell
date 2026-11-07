pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var audio: sink ? sink.audio : null
    readonly property var sourceAudio: source ? source.audio : null
    readonly property bool ready: Pipewire.ready
    readonly property bool muted: audio ? audio.muted : false
    readonly property bool sourceMuted: sourceAudio ? sourceAudio.muted : false
    readonly property real volume: audio ? audio.volume : 0
    readonly property int volumePercent: Math.round(volume * 100)

    readonly property var sinks: {
        const result = [];
        const list = Pipewire.nodes ? Pipewire.nodes.values : [];
        for (let i = 0; i < list.length; i++) {
            const node = list[i];
            if (node && (node.type & PwNodeType.AudioSink))
                result.push(node);
        }
        result.sort((a, b) => (a.description || a.name || "").localeCompare(b.description || b.name || ""));
        return result;
    }

    readonly property var sources: {
        const result = [];
        const sinkNames = ({});
        for (let i = 0; i < sinks.length; i++)
            sinkNames[sinks[i].name] = true;
        const list = Pipewire.nodes ? Pipewire.nodes.values : [];
        for (let i = 0; i < list.length; i++) {
            const node = list[i];
            if (node && (node.type & PwNodeType.AudioSource) && !sinkNames[node.name])
                result.push(node);
        }
        result.sort((a, b) => (a.description || a.name || "").localeCompare(b.description || b.name || ""));
        return result;
    }

    function setVolume(value) {
        if (!audio)
            return;
        audio.volume = Math.max(0, Math.min(1.5, value));
    }

    function adjustVolume(delta) {
        setVolume(volume + delta);
    }

    function toggleMute() {
        if (audio)
            audio.muted = !audio.muted;
    }

    function toggleSourceMute() {
        if (sourceAudio)
            sourceAudio.muted = !sourceAudio.muted;
    }

    function setDefaultSink(node) {
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node) {
        if (node)
            Pipewire.preferredDefaultAudioSource = node;
    }

    function isDefaultSink(node) {
        return node !== null && node === Pipewire.defaultAudioSink;
    }

    function isDefaultSource(node) {
        return node !== null && node === Pipewire.defaultAudioSource;
    }
}
