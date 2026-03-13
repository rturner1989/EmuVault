import { Application } from "@hotwired/stimulus"
import DialogController from "./dialog_controller"
import SaveHintController from "./save_hint_controller"

const application = Application.start()
application.register("dialog", DialogController)
application.register("save-hint", SaveHintController)
