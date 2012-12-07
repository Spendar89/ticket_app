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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121207010035) do

  create_table "games", :force => true do |t|
    t.integer  "team_id"
    t.string   "opponent"
    t.string   "stubhub_id"
    t.string   "date"
    t.integer  "average_price"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.boolean  "home"
    t.string   "venue"
    t.integer  "latitude"
    t.integer  "longitude"
    t.integer  "popularity"
    t.integer  "relative_popularity"
    t.integer  "relative_price"
  end

  create_table "searches", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.integer  "best_game_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "arena_image"
    t.integer  "home_average_price"
    t.integer  "away_average_price"
    t.integer  "home_average_popularity"
    t.integer  "home_standard_deviation"
    t.integer  "home_price_standard_deviation"
    t.integer  "away_price_standard_deviation"
    t.string   "url"
  end

end
