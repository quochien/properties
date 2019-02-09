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

ActiveRecord::Schema.define(version: 2019_02_09_080333) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lots", force: :cascade do |t|
    t.integer "site_id"
    t.integer "programme_id"
    t.string "lot_source_id"
    t.string "programme_source_id"
    t.string "terrasse_text"
    t.string "parking_text"
    t.string "images"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notary_fee"
    t.string "security_deposit"
    t.string "lot_name"
    t.string "full_desc"
    t.string "city_text"
    t.string "expected_delivery"
    t.string "expected_actability"
    t.string "price_text"
    t.string "ville"
    t.string "postal_code"
    t.string "department"
    t.integer "price"
    t.string "disponibilite"
    t.string "lot_type"
    t.string "superficie"
    t.integer "etage"
    t.string "zone"
    t.string "fiscalite"
    t.string "reference"
    t.float "size"
    t.string "region"
    t.string "market_rental"
    t.string "rentabilite"
    t.string "pinel_rental"
    t.string "pinel_rentabilite"
    t.string "price_without_vat_exclude_furniture"
    t.string "loyer_ht"
    t.string "price_of_furniture_exclude_vat"
    t.string "total_price_exclude_vat"
    t.string "gestionnaire"
    t.string "dureedubail"
    t.string "logements"
    t.string "pleine_propriete"
    t.string "usufruitier"
    t.string "duree_usufruit_temporaire"
    t.string "price_without_construction"
    t.string "additional_price_construction"
    t.string "parking_price"
    t.string "cellar_price"
    t.string "subsidy"
    t.string "address"
    t.string "prix_ht"
    t.string "loyer_pinel"
    t.string "prix_ht_mobilier"
    t.string "loyer"
    t.string "exposition"
    t.string "vat_rate"
    t.string "jardin"
    t.string "balcon"
    t.string "depot_de_garantie"
    t.string "frais_de_notaire"
    t.string "pls"
  end

  create_table "programmes", force: :cascade do |t|
    t.string "programme_name"
    t.string "images"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_id"
    t.integer "site_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "site_name", null: false
    t.string "url", null: false
    t.string "logo"
  end

end
