import { createConsumer } from "@rails/actioncable"

let consumer

export function getConsumer() {
  return consumer || (consumer = createConsumer())
}

export async function subscribeTo(channel, mixin) {
  const { subscriptions } = getConsumer()
  return subscriptions.create(channel, mixin)
}
