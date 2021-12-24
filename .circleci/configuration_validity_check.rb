# frozen_string_literal: true

require 'rubygems'

VALID_CONFIGURATIONS = {
  '2.5' => { lower: '5.2', upper: '7.0' },
  '2.6' => { lower: '5.2', upper: '7.0' },
  '2.7' => { lower: '5.2' },
  '3.0' => { lower: '6.1' },
}.freeze

if ARGV.length != 2
  puts "Usage: ruby configuration_validity_check.rb <ruby version> <activerecord version>"
  exit 1
end

ruby_version = Gem::Version.new(ARGV[0])
bounds = VALID_CONFIGURATIONS.fetch(ARGV[0])
active_record_version = Gem::Version.new(ARGV[1])
lower_bound = Gem::Version.new(bounds[:lower])
upper_bound = Gem::Version.new(bounds[:upper]) if bounds[:upper]

if active_record_version < lower_bound
  puts 'no'
  exit
end

if upper_bound && active_record_version >= upper_bound
  puts 'no'
  exit
end

puts 'yes'
