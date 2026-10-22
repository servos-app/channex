# frozen_string_literal: true

require_relative "lib/channex/version"

Gem::Specification.new do |spec|
  spec.name = "channex"
  spec.version = Channex::VERSION
  spec.authors = ["asgerb"]
  spec.email = ["a@asgerbehnckejacobsen.dk"]

  spec.summary = "Ruby client for the Channex.io channel manager API"
  spec.description = "A clean, idiomatic Ruby library for the Channex.io channel manager API: properties, room types, rate plans, availability, restrictions, bookings, webhooks, and more."
  spec.homepage = "https://github.com/servos-app/channex"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  # Private gem — block accidental publish to the public RubyGems host.
  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/servos-app"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 7.1"
  spec.add_dependency "zeitwerk", "~> 2.6"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
