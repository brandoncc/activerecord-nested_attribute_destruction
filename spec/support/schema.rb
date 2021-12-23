# frozen_string_literal: true

ActiveRecord::Schema.define(version: 1) do
  self.verbose = false

  create_table "harbors", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "ships", force: :cascade do |t|
    t.integer "harbor_id", null: false
    t.integer "fuel_remaining"
  end

  create_table "lighthouses", force: :cascade do |t|
    t.integer "harbor_id", null: false
    t.string "name"
  end
end
