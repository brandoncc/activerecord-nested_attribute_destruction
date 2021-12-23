# frozen_string_literal: true

ActiveRecord::Schema.define(version: 1) do
  self.verbose = false

  create_table "harbors", force: :cascade do |t|
    t.string "name", null: false

    t.timestamps
  end

  create_table "ships", force: :cascade do |t|
    t.integer "harbor_id", null: false

    t.timestamps
  end
end
