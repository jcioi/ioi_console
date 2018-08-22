# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_08_22_161455) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contests", force: :cascade do |t|
    t.string "name"
    t.string "cms_contest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "desk_assignment_histories", force: :cascade do |t|
    t.bigint "desk_id"
    t.bigint "contestant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "machine_id"
    t.index ["contestant_id"], name: "index_desk_assignment_histories_on_contestant_id"
    t.index ["desk_id"], name: "index_desk_assignment_histories_on_desk_id"
    t.index ["machine_id"], name: "index_desk_assignment_histories_on_machine_id"
  end

  create_table "desks", force: :cascade do |t|
    t.string "name"
    t.bigint "floor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "contestant_id"
    t.bigint "machine_id"
    t.index ["contestant_id"], name: "index_desks_on_contestant_id"
    t.index ["floor_id"], name: "index_desks_on_floor_id"
    t.index ["machine_id"], name: "index_desks_on_machine_id"
    t.index ["name"], name: "index_desks_on_name"
  end

  create_table "floors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_floors_on_name"
  end

  create_table "machines", force: :cascade do |t|
    t.string "mac"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mac"], name: "index_machines_on_mac"
  end

  create_table "password_tiers", force: :cascade do |t|
    t.string "description"
    t.datetime "not_before"
    t.datetime "not_after"
    t.bigint "contest_id"
    t.index ["contest_id"], name: "index_password_tiers_on_contest_id"
  end

  create_table "passwords", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "password_tier_id"
    t.string "plaintext_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["password_tier_id"], name: "index_passwords_on_password_tier_id"
    t.index ["person_id", "password_tier_id"], name: "index_passwords_on_person_id_and_password_tier_id", unique: true
    t.index ["person_id"], name: "index_passwords_on_person_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name", null: false
    t.string "login", null: false
    t.string "avatar_url"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.bigint "team_id"
    t.text "special_requirement_note"
    t.index ["login"], name: "index_people_on_login"
    t.index ["role"], name: "index_people_on_role"
    t.index ["team_id"], name: "index_people_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_teams_on_slug"
  end

  add_foreign_key "desk_assignment_histories", "desks"
  add_foreign_key "desk_assignment_histories", "machines"
  add_foreign_key "desk_assignment_histories", "people", column: "contestant_id"
  add_foreign_key "desks", "floors"
  add_foreign_key "desks", "machines"
  add_foreign_key "desks", "people", column: "contestant_id"
  add_foreign_key "password_tiers", "contests"
  add_foreign_key "passwords", "password_tiers"
  add_foreign_key "passwords", "people"
  add_foreign_key "people", "teams"
end
