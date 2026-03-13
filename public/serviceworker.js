self.addEventListener("push", function (event) {
  if (!event.data) return;

  const data = event.data.json();
  const url = new URL(data.path || "/", self.location.origin).href;

  event.waitUntil(
    self.registration.showNotification(data.title || "EmuVault", {
      body: data.body,
      icon: "/icon.png",
      badge: "/icon.png",
      data: { url },
    })
  );
});

self.addEventListener("notificationclick", function (event) {
  event.notification.close();

  const url = event.notification.data.url;

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then(function (clientList) {
      for (const client of clientList) {
        if (client.url === url && "focus" in client) return client.focus();
      }
      if (clients.openWindow) return clients.openWindow(url);
    })
  );
});
