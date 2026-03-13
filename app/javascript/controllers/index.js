import { Application } from "@hotwired/stimulus"
import AutoSubmitController from "./auto_submit_controller"
import DialogController from "./dialog_controller"
import NotificationsController from "./notifications_controller"
import PushSubscriptionController from "./push_subscription_controller"
import SaveHintController from "./save_hint_controller"

const application = Application.start()
application.register("auto-submit", AutoSubmitController)
application.register("dialog", DialogController)
application.register("notifications", NotificationsController)
application.register("push-subscription", PushSubscriptionController)
application.register("save-hint", SaveHintController)
