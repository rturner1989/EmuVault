import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { vapidPublicKey: String }
  static targets = ["button", "status"]

  async subscribe() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
      this.setStatus("Push notifications are not supported on this browser.")
      return
    }

    const permission = await Notification.requestPermission()
    if (permission !== "granted") {
      this.setStatus("Permission denied.")
      return
    }

    try {
      const registration = await navigator.serviceWorker.ready
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicKeyValue),
      })

      const response = await fetch("/web_push_subscriptions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("[name='csrf-token']")?.content || "",
        },
        body: JSON.stringify({
          web_push_subscription: {
            endpoint: subscription.endpoint,
            p256dh: btoa(String.fromCharCode(...new Uint8Array(subscription.getKey("p256dh")))),
            auth: btoa(String.fromCharCode(...new Uint8Array(subscription.getKey("auth")))),
          },
        }),
      })

      if (response.ok) {
        this.setStatus("Push notifications enabled.")
        if (this.hasButtonTarget) this.buttonTarget.disabled = true
      }
    } catch (err) {
      this.setStatus("Could not subscribe: " + err.message)
    }
  }

  setStatus(message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message
  }

  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
    const rawData = window.atob(base64)
    return Uint8Array.from([...rawData].map((char) => char.charCodeAt(0)))
  }
}
