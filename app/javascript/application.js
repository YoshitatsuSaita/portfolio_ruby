import "@hotwired/turbo-rails"

import { Application } from "@hotwired/stimulus"
const application = Application.start()

import CharCountController from "controllers/char_count_controller"
application.register("char-count", CharCountController)
