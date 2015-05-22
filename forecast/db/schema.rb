# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150522045911) do

  create_table "descriptions", force: :cascade do |t|
    t.float    "temp"
    t.float    "rainfall"
    t.float    "windSpeed"
    t.string   "windDirection"
    t.time     "datetime"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "location_id"
  end

  add_index "descriptions", ["location_id"], name: "index_descriptions_on_location_id"

  create_table "locations", force: :cascade do |t|
    t.text     "location_id"
    t.integer  "post_code"
    t.float    "lat"
    t.float    "long"
    t.datetime "latest_update"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
