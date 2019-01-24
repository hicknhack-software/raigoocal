
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "raigoocal/version"

Gem::Specification.new do |spec|
  spec.name          = "raigoocal"
  spec.version       = Raigoocal::VERSION
  spec.authors       = ["Andreas Schau"]
  spec.email         = ["andreas.schau@hicknhack-software.com"]

  spec.summary       = %q{This gem provides functionality to handle the loading of event data from a public google calendar via an api key. (Without the need for OAuth.)}
  spec.description   = %q{It does so by offering functions that gather the event data, cache it and structure it in a way that makes it easy to display in an agenda or monthly overview-like style.}
  spec.homepage      = "https://www.hicknhack-software.com/it-events"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  #   spec.metadata["homepage_uri"] = spec.homepage
  #   spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #   spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  # Library that helps get more functionality that typically comes with rails applications
  spec.add_development_dependency "activesupport", "~> 5.0", ">= 5.0.0.1"
end
