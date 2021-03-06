# activerecord-nested\_attribute\_destruction

Build status for all matrix combinations listed in [compatibility](#compatibility)

[![CircleCI](https://circleci.com/gh/brandoncc/activerecord-nested_attribute_destruction.svg?style=svg)](https://circleci.com/gh/brandoncc/activerecord-nested_attribute_destruction)

## TL;DR

```ruby
class Harbor
  has_many :ships

  accepts_nested_attributes_for :ships, allow_destroy: true
end

harbor.ships_attributes = [harbor.ships.first.attributes.merge('_destroy': true)]
harbor.save!

harbor.ships_destroyed_during_save? # true
```

See that last line of code? That is what this gem adds :smiley:

## Description

Active Record offers introspection of saved changes for almost everything you
could want. The one thing I have repeatedly found myself wishing for was a way
to know if a nested attribute was destroyed during save via
accepts\_nested\_attributes.

The only way I know to find that information is to set a flag in a callback
before saving, then use that flag for state comparison after the save completes.

This gem handles setting the flags before saving and adds introspection into
the state after the save.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-nested_attribute_destruction'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activerecord-nested_attribute_destruction

## Usage

### API

When you call `#accepts_nested_attributes_for`, this gem will automatically
install its hooks on the class. One method is also added to the class instance
API: `<association_name>_destroyed_during_save?`.

For example:

```ruby
has_many :ships
has_one  :accountant

accepts_nested_attributes_for :ships, :accountant, allow_destroy: true
```

You can call `ships_destroyed_during_save?` and
`accountant_destroyed_during_save?` after a save to check if associated ships or
the accountant were destroyed through nested attribute assignment during the
save.

### Example

Here is an example of how it works, adapted from the test suite.

```ruby
def print_result(h)
  if h.ships_destroyed_during_save?
    puts "At least one ship was destroyed during the last save operation"
  else
    puts "No ships were destroyed during the last save operation"
  end
end

harbor = DangerousHarbor.create(name: 'Blue Lagoon')
ship1 = (harbor.ships << Ship.create(harbor: harbor)).first
ship2 = (harbor.ships << Ship.create(harbor: harbor)).first

harbor.ships_attributes = [
  ship1.attributes.merge('_destroy': true),
  ship2.attributes.merge(fuel_remaining: 10)
]

harbor.save!
print_result(harbor)

harbor.save!
print_result(harbor)
```

and the output when the code above is run:

```
At least one ship was destroyed during the last save operation
No ships were destroyed during the last save operation
```

To see more examples, take a look at [the tests](https://github.com/brandoncc/activerecord-nested_attribute_destruction/blob/main/spec/functionality_spec.rb).

## Compatibility

This gem should be compatible with all versions of Ruby 2.3 and higher. It
should be compatible with Active Record versions 5.2 and up.

Because of rubocop dependencies and keyword arguments changes in Ruby 3.0 which
affected the database setup code used in the test suite, it is only tested
against the matrices displayed below.

### Sorted by Active Record version

| Active Record version | Ruby Version |
|-----------------------|--------------|
| 5.2                   | 2.5          |
| 5.2                   | 2.6          |
| 5.2                   | 2.7          |
| 6.0                   | 2.5          |
| 6.0                   | 2.6          |
| 6.0                   | 2.7          |
| 6.1                   | 2.5          |
| 6.1                   | 2.6          |
| 6.1                   | 2.7          |
| 6.1                   | 3.0          |
| 7.0                   | 2.7          |
| 7.0                   | 3.0          |

### Sorted by Ruby version

| Ruby Version | Active Record version |
|--------------|-----------------------|
| 2.5          | 5.2                   |
| 2.5          | 6.0                   |
| 2.5          | 6.1                   |
| 2.6          | 5.2                   |
| 2.6          | 6.0                   |
| 2.6          | 6.1                   |
| 2.7          | 5.2                   |
| 2.7          | 6.0                   |
| 2.7          | 6.1                   |
| 2.7          | 7.0                   |
| 3.0          | 6.1                   |
| 3.0          | 7.0                   |

### Specific requirements

#### Ruby

The safe navigation operator, introduced in Ruby 2.3, is used.

#### Active Record

The [API changes](https://www.fastruby.io/blog/rails/upgrades/active-record-5-1-api-changes.html)
in Active Record 5.2 are necessary for the core functionality of the gem.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/brandoncc/activerecord-nested\_attribute\_destruction. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/brandoncc/activerecord-nested_attribute_destruction/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/brandoncc/activerecord-nested_attribute_destruction/blob/main/CODE_OF_CONDUCT.md).
