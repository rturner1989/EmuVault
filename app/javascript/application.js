import "@hotwired/turbo"
import "./turbo/cable_stream_source_element"
import "./controllers"

if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/serviceworker.js").catch(function (err) {
    console.warn("Service worker registration failed:", err)
  })
}
