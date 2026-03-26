import * as Turbo from "@hotwired/turbo"

// Custom Turbo Stream actions for a11y-dialog integration.
// Dispatches events on the target element that the dialog Stimulus controller handles.

Turbo.StreamActions.close_dialog = function() {
  document.getElementById(this.target)?.dispatchEvent(new CustomEvent("dialog:close"))
}

Turbo.StreamActions.open_dialog = function() {
  document.getElementById(this.target)?.dispatchEvent(new CustomEvent("dialog:open"))
}
