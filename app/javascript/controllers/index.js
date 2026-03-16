import { Application } from "@hotwired/stimulus"
import AutoSubmitController from "./auto_submit_controller"
import DialogController from "./dialog_controller"
import DirectoryBrowserController from "./directory_browser_controller"
import NotificationsController from "./notifications_controller"
import OnboardingController from "./onboarding_controller"
import PushSubscriptionController from "./push_subscription_controller"
import QuickSyncController from "./quick_sync_controller"
import SaveHintController from "./save_hint_controller"

const application = Application.start()
application.register("auto-submit", AutoSubmitController)
application.register("dialog", DialogController)
application.register("directory-browser", DirectoryBrowserController)
application.register("notifications", NotificationsController)
application.register("onboarding", OnboardingController)
application.register("push-subscription", PushSubscriptionController)
application.register("quick-sync", QuickSyncController)
application.register("save-hint", SaveHintController)
