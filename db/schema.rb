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

ActiveRecord::Schema.define(version: 20160322143957) do

  create_table "attachments", force: :cascade do |t|
    t.text     "message_id",                 limit: 65535, null: false
    t.string   "attached_file_file_name",    limit: 255
    t.string   "attached_file_content_type", limit: 255
    t.integer  "attached_file_file_size",    limit: 4
    t.datetime "attached_file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: :cascade do |t|
    t.text     "message_id", limit: 65535, null: false
    t.text     "subject",    limit: 65535
    t.text     "to",         limit: 65535
    t.text     "from",       limit: 65535
    t.text     "html_body",  limit: 65535
    t.text     "text_body",  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings_emails", force: :cascade do |t|
    t.text     "username",   limit: 65535
    t.text     "password",   limit: 65535
    t.string   "server",     limit: 255
    t.integer  "port",       limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

end

