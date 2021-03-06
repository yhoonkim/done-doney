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

ActiveRecord::Schema.define(version: 20150709134703) do

  create_table "authorizations", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "access_token"
    t.integer  "root_revision", default: 0
  end

  create_table "lists", force: :cascade do |t|
    t.datetime "original_created_at"
    t.string   "title"
    t.string   "list_type"
    t.string   "type"
    t.integer  "revision"
    t.string   "name"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "list_id"
    t.integer  "user_id"
    t.integer  "revision"
    t.string   "state"
    t.boolean  "owner"
    t.boolean  "muted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subtasks", force: :cascade do |t|
    t.datetime "original_created_at"
    t.integer  "created_by_id"
    t.integer  "task_id"
    t.integer  "revision"
    t.integer  "point"
    t.string   "title"
    t.integer  "completed_by_id"
    t.datetime "completed_at"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.integer  "assignee_id"
    t.integer  "assigner_id"
    t.datetime "original_created_at"
    t.integer  "created_by_id"
    t.date     "due_date"
    t.integer  "list_id"
    t.integer  "revision"
    t.boolean  "starred"
    t.string   "title"
    t.integer  "completed_by_id"
    t.datetime "completed_at"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "point"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "uid"
    t.string   "time_zone",  default: "Seoul"
  end

end
