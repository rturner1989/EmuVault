// iOS-safe scroll lock. `overflow: hidden` on body alone doesn't prevent
// touch-scroll on mobile Safari. Saving scroll position + position:fixed does.
let scrollY = 0

export function lockScroll() {
  scrollY = window.scrollY
  Object.assign(document.body.style, {
    overflow: "hidden",
    position: "fixed",
    top: `-${scrollY}px`,
    width: "100%",
  })
}

export function unlockScroll() {
  Object.assign(document.body.style, {
    overflow: "",
    position: "",
    top: "",
    width: "",
  })
  window.scrollTo(0, scrollY)
}
