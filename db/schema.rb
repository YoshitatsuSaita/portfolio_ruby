# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_06_30_103123) do
  create_table "haikus", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "body", null: false
    t.string "kigo", null: false
    t.string "theme"
    t.text "description"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_haikus_on_user_id"
  end

  create_table "kigo_explanations", charset: "utf8mb4", force: :cascade do |t|
    t.string "kigo_word", null: false
    t.string "canonical_word"
    t.string "parent_kigo"
    t.string "season", null: false
    t.text "explanation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "child_kigo"
    t.index ["kigo_word"], name: "index_kigo_explanations_on_kigo_word", unique: true
  end

  create_table "reviews", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "haiku_id", null: false
    t.integer "score", null: false
    t.text "comment"
    t.string "correction_body"
    t.text "correction_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["haiku_id"], name: "index_reviews_on_haiku_id"
    t.index ["user_id", "haiku_id"], name: "index_reviews_on_user_id_and_haiku_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "topic_assignments", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "user_id", null: false
    t.string "theme", null: false
    t.text "message"
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "deadline"
    t.boolean "reviewed", default: false, null: false
    t.index ["sender_id"], name: "index_topic_assignments_on_sender_id"
    t.index ["user_id"], name: "index_topic_assignments_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.text "profile_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "guest", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "haikus", "users"
  add_foreign_key "reviews", "haikus"
  add_foreign_key "reviews", "users"
  add_foreign_key "topic_assignments", "users"
  add_foreign_key "topic_assignments", "users", column: "sender_id"
end
