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

ActiveRecord::Schema.define(:version => 20121216001624) do

  create_table "games", :force => true do |t|
    t.integer  "team_id"
    t.string   "opponent"
    t.string   "stubhub_id"
    t.string   "date"
    t.integer  "average_price"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.boolean  "home"
    t.string   "venue"
    t.integer  "latitude"
    t.integer  "longitude"
    t.integer  "popularity"
    t.integer  "relative_popularity"
    t.integer  "relative_price"
    t.decimal  "popularity_multiplier"
  end

  create_table "searches", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sections", :force => true do |t|
    t.integer  "team_id"
    t.integer  "average_price"
    t.integer  "std_dev"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "name"
    t.string   "seat_view_url"
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
    t.text     "section_averages"
    t.text     "section_standard_deviations"
    t.text     "seat_views"
    t.string   "conference"
    t.string   "record"
    t.string   "venue_name"
    t.string   "venue_address"
    t.string   "division"
    t.string   "last_5"
    t.integer  "pop_std_dev"
    t.integer  "average_popularity"
  end

  create_table "tickets", :force => true do |t|
    t.integer  "game_id"
    t.string   "url"
    t.integer  "stubhub_id"
    t.integer  "price"
    t.string   "row"
    t.integer  "quantity"
    t.integer  "section_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
