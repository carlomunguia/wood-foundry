// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import Alpine from "alpinejs";

// Import local files
//
import socket from "./socket";
import Video from "./video";

// LiveView Hooks
let Hooks = {};

Hooks.VideoPlayer = {
  mounted() {
    const playerId = this.el.dataset.playerId;
    const videoId = this.el.dataset.videoId;

    if (playerId) {
      this.loadYouTubePlayer(playerId);
    }

    // Handle seek events from LiveView
    this.handleEvent("seek_video", ({ time }) => {
      if (this.player && this.player.seekTo) {
        this.player.seekTo(time);
      }
    });
  },

  loadYouTubePlayer(playerId) {
    // Load YouTube IFrame API if not already loaded
    if (!window.YT) {
      const script = document.createElement("script");
      script.src = "https://www.youtube.com/iframe_api";
      document.head.appendChild(script);

      window.onYouTubeIframeAPIReady = () => {
        this.createPlayer(playerId);
      };
    } else {
      this.createPlayer(playerId);
    }
  },

  createPlayer(playerId) {
    this.player = new YT.Player(this.el, {
      height: "100%",
      width: "100%",
      videoId: playerId,
      events: {
        onStateChange: (event) => {
          // Send time updates to LiveView
          if (this.timeInterval) clearInterval(this.timeInterval);

          this.timeInterval = setInterval(() => {
            if (this.player && this.player.getCurrentTime) {
              const currentTime = Math.floor(this.player.getCurrentTime());
              this.pushEvent("update_time", { time: currentTime });
            }
          }, 1000);
        },
      },
    });
  },
};

// Initialize LiveView
let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Configure LiveView
liveSocket.enableLatencySim(0);

// Initialize Alpine.js
window.Alpine = Alpine;
Alpine.start();

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// Legacy video initialization for channels
const video = document.getElementById("video");
if (video) {
  Video.init(socket, video);
}

// Mobile menu toggle
document.addEventListener("DOMContentLoaded", () => {
  const menuToggle = document.getElementById("mobile-menu-toggle");
  const mobileMenu = document.getElementById("mobile-menu");

  if (menuToggle && mobileMenu) {
    menuToggle.addEventListener("click", (e) => {
      e.stopPropagation();
      mobileMenu.classList.toggle("active");
    });

    // Close menu when clicking outside
    document.addEventListener("click", (e) => {
      if (
        mobileMenu.classList.contains("active") &&
        !mobileMenu.contains(e.target) &&
        !menuToggle.contains(e.target)
      ) {
        mobileMenu.classList.remove("active");
      }
    });

    // Close menu when clicking a link
    const mobileNavLinks = mobileMenu.querySelectorAll(".mobile-nav-link");
    mobileNavLinks.forEach((link) => {
      link.addEventListener("click", () => {
        mobileMenu.classList.remove("active");
      });
    });
  }
});
