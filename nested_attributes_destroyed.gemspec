# frozen_string_literal: true

require_relative "lib/nested_attributes_destroyed/version"

Gem::Specification.new do |spec|
  spec.name          = "nested_attributes_destroyed"
  spec.version       = NestedAttributesDestroyed::VERSION
  spec.authors       = ["Brandon Conway"]
  spec.email         = ["brandoncc@gmail.com"]

  spec.summary       = "Nested attributes destroyed"
  spec.description   = "Add methods to nested attribute collections to check if any were destroyed"
  spec.homepage      = "https://github.com/brandoncc/nested_attributes_destroyed"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/brandoncc/nested_attributes_destroyed"
  spec.metadata["changelog_uri"] = "https://github.com/brandoncc/nested_attributes_destroyed/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
