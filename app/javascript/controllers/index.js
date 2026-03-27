import { Application } from "@hotwired/stimulus"

const application = Application.start()

import AutoSubmitController from "./auto_submit_controller"
application.register("auto-submit", AutoSubmitController)

import DialogController from "./dialog_controller"
application.register("dialog", DialogController)

import DirectoryBrowserController from "./directory_browser_controller"
application.register("directory-browser", DirectoryBrowserController)

import FilePickerController from "./file_picker_controller"
application.register("file-picker", FilePickerController)

import FlashController from "./flash_controller"
application.register("flash", FlashController)

import IframeDownloadController from "./iframe_download_controller"
application.register("iframe-download", IframeDownloadController)

import NotificationsController from "./notifications_controller"
application.register("notifications", NotificationsController)

import OnboardingController from "./onboarding_controller"
application.register("onboarding", OnboardingController)

import ProfileSelectController from "./profile_select_controller"
application.register("profile-select", ProfileSelectController)

import PushSubscriptionController from "./push_subscription_controller"
application.register("push-subscription", PushSubscriptionController)

import QuickSyncController from "./quick_sync_controller"
application.register("quick-sync", QuickSyncController)

import SaveHintController from "./save_hint_controller"
application.register("save-hint", SaveHintController)

import SwipeDismissController from "./swipe_dismiss_controller"
application.register("swipe-dismiss", SwipeDismissController)

import ThemeController from "./theme_controller"
application.register("theme", ThemeController)

import ViewToggleController from "./view_toggle_controller"
application.register("view-toggle", ViewToggleController)
