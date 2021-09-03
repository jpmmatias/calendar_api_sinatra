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

ActiveRecord::Schema.define(version: 2021_09_02_125855) do

  create_table "documents", force: :cascade do |t|
    t.integer "event_id"
    t.string "file_path", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "file_type"
    t.string "file_name"
    t.index ["event_id"], name: "index_documents_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "local"
    t.text "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "owner_id"
    t.index ["owner_id"], name: "index_events_on_owner_id"
  end

  create_table "invites", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.integer "sender_id", null: false
    t.integer "reciver_id", null: false
    t.integer "event_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_invites_on_event_id"
    t.index ["reciver_id"], name: "index_invites_on_reciver_id"
    t.index ["sender_id"], name: "index_invites_on_sender_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "documents", "events"
  add_foreign_key "events", "users", column: "owner_id"
  add_foreign_key "invites", "events", on_delete: :cascade
  add_foreign_key "invites", "users", column: "reciver_id", on_delete: :cascade
  add_foreign_key "invites", "users", column: "sender_id", on_delete: :cascade
end
