import "@hotwired/turbo"
import "./turbo/cable_stream_source_element"
import "./controllers"

// Show progress bar immediately on navigation (default is 500ms delay)
Turbo.config.drive.progressBarDelay = 0

// Custom Turbo Stream action: dispatches a "dialog:close" event on the target
// element, which the dialog Stimulus controller handles to hide the dialog.
Turbo.StreamActions.close_dialog = function() {
  document.getElementById(this.target)?.dispatchEvent(new CustomEvent("dialog:close"))
}

// Reset all forms inside dialogs before Turbo caches the page,
// so restored snapshots don't show stale values or validation errors
document.addEventListener("turbo:before-cache", () => {
  document.querySelectorAll(".dialog-container form").forEach(form => {
    form.reset()
    form.querySelectorAll(".field_with_errors").forEach(wrapper => {
      wrapper.replaceWith(...wrapper.childNodes)
    })
    form.querySelectorAll("span.error").forEach(el => el.remove())
  })
})

if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/serviceworker.js").catch(function (err) {
    console.warn("Service worker registration failed:", err)
  })
}
