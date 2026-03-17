// Scroll lock that avoids the position:fixed body hack.
// The old approach (position:fixed + top:-Npx on body) caused layout reflow
// that made the fixed bottom nav visually jump on close.
let scrollY = 0
let lockCount = 0

// Prevents background scroll on iOS Safari when a dialog is open.
// Allows scrolling inside the dialog content itself (overflow-y: auto elements).
function preventBackgroundScroll(event) {
  let target = event.target
  // Walk up from the touch target to find a scrollable dialog element
  while (target && target !== document.body && target !== document.documentElement) {
    const style = window.getComputedStyle(target)
    const isScrollable =
      (style.overflowY === "auto" || style.overflowY === "scroll") &&
      target.scrollHeight > target.clientHeight
    if (isScrollable) return // allow scroll inside dialog content
    target = target.parentElement
  }
  // No scrollable ancestor found — block the touch to prevent background scroll
  event.preventDefault()
}

export function lockScroll() {
  lockCount++
  if (lockCount > 1) return

  scrollY = window.scrollY
  document.documentElement.style.overflow = "hidden"
  document.body.style.overflow = "hidden"
  document.body.style.touchAction = "none"
  document.body.style.overscrollBehavior = "none"
  document.addEventListener("touchmove", preventBackgroundScroll, { passive: false })
}

export function unlockScroll() {
  lockCount = Math.max(0, lockCount - 1)
  if (lockCount > 0) return

  document.documentElement.style.overflow = ""
  document.body.style.overflow = ""
  document.body.style.touchAction = ""
  document.body.style.overscrollBehavior = ""
  document.removeEventListener("touchmove", preventBackgroundScroll)
  window.scrollTo(0, scrollY)
}
