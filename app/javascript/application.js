import "@hotwired/turbo-rails"

import { Application } from "@hotwired/stimulus"
const application = Application.start()

import CharCountController from "controllers/char_count_controller"
application.register("char-count", CharCountController)

import BlindAuthorController from "controllers/blind_author_controller"
application.register("blind-author", BlindAuthorController)

import ModalController from "controllers/modal_controller"
application.register("modal", ModalController)

import SelectAllController from "controllers/select_all_controller"
application.register("select-all", SelectAllController)
