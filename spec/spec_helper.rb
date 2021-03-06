# frozen_string_literal: true

require "rubygems"
require "active_record/railtie"
require "bundler/setup"
require "nested_attribute_destruction"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

Dir["support/**/*.rb"].each do |f|
  require_relative f unless f == "spec/support/schema.rb"
end

load "support/schema.rb"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
