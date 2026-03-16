import { Controller } from "@hotwired/stimulus"
import { driver } from "driver.js"

export default class extends Controller {
  static values = { active: Boolean }

  connect() {
    if (this.activeValue) this.startTour()
  }

  startTour() {
    const mobile = window.innerWidth < 1024

    const driverObj = driver({
      showProgress: true,
      progressText: "{{current}} of {{total}}",
      nextBtnText: "Next →",
      prevBtnText: "← Back",
      doneBtnText: "Let's go!",
      smoothScroll: true,
      steps: [
        {
          popover: {
            title: "Welcome to EmuVault",
            description: "Your save files are in one place. Let's take a quick look around.",
          },
        },
        {
          element: "#add-game-btn",
          popover: {
            title: "Add a game",
            description: "Start here. Add a game to your library, then upload a save file and sync it between emulators.",
            side: "bottom",
          },
        },
        {
          element: mobile ? "#mobile-nav-games" : "#nav-games",
          popover: {
            title: "Games library",
            description: "All your games live here. Tap a game to view its saves, upload a new version, or download for a specific emulator.",
            side: mobile ? "top" : "right",
          },
        },
        {
          element: mobile ? "#mobile-nav-activity" : "#nav-activity",
          popover: {
            title: "Activity log",
            description: "Every upload and download is recorded here — when it happened, which device, and from where. Great for spotting sync issues.",
            side: mobile ? "top" : "right",
          },
        },
        {
          element: mobile ? "#mobile-nav-profiles" : "#nav-profiles",
          popover: {
            title: "Emulator profiles",
            description: "Manage which emulators you use and configure their save directories. EmuVault uses these to rename files correctly on download.",
            side: mobile ? "top" : "right",
          },
        },
        {
          element: mobile ? "#mobile-nav-notifications" : "#nav-notifications",
          popover: {
            title: "Notifications",
            description: "Get notified when a new save is uploaded from another device. Install EmuVault as a home screen app to receive push notifications.",
            side: mobile ? "top" : "right",
          },
        },
        {
          element: mobile ? "#mobile-nav-settings" : "#nav-settings",
          popover: {
            title: "Settings",
            description: "Configure scan paths to auto-discover games, set up the auto-scan schedule, and manage your account.",
            side: mobile ? "top" : "right",
          },
        },
      ],
    })

    driverObj.drive()
  }
}
