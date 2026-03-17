// Scroll lock that avoids the position:fixed body hack.
// The old approach (position:fixed + top:-Npx on body) caused layout reflow
// that made the fixed bottom nav visually jump on close.
let scrollY = 0
let lockCount = 0

export function lockScroll() {
  lockCount++
  if (lockCount > 1) return

  scrollY = window.scrollY
  document.documentElement.style.overflow = "hidden"
  document.body.style.overflow = "hidden"
  document.body.style.touchAction = "none"
  document.body.style.overscrollBehavior = "none"
}

export function unlockScroll() {
  lockCount = Math.max(0, lockCount - 1)
  if (lockCount > 0) return

  document.documentElement.style.overflow = ""
  document.body.style.overflow = ""
  document.body.style.touchAction = ""
  document.body.style.overscrollBehavior = ""
  window.scrollTo(0, scrollY)
}
