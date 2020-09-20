let Player = {
    player: null,

    init(domId, playerId, onReady) {
        window.onYouTubeIframeAPIReady = () => {
            this.IframeReady(domId, playerId, onReady)
        }
        let youtubeScriptTag = document.createElement("script")
        youtubeScriptTag.src = "//www.youtube.com/iframe_api"
        document.head.appendChild(youtubeScriptTag)
    },

    onIframeReady(domId, playerId, onReady) {
        this.player = new YT.player(domId, {
            height: "360",
            width: "420",
            videoId: playerId,
            events: {
                "onReady": (event => onReady(event)),
                "onStateChange": (event => this.onPlayerStateChange(event))
            }
        })
    },
    onPlayerStateChange(event) {
    },
    getCurrentTime() {
        return Math.floor(this.player.getCurrentTime() * 1000)
    },
    seekTo(millSec) {
        return this.player.seekTo(millSec / 1000)
    }
}
export default Player
