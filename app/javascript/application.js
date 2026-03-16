import "@hotwired/turbo"
import "./turbo/cable_stream_source_element"
import "./controllers"

// Show progress bar immediately on navigation (default is 500ms delay)
Turbo.config.drive.progressBarDelay = 0

if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/serviceworker.js").catch(function (err) {
    console.warn("Service worker registration failed:", err)
  })
}
