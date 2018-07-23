# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'koha_ils/version'

Gem::Specification.new do |spec|
  spec.name          = 'koha_ils'
  spec.version       = KohaIls::VERSION
  spec.authors       = ['Ronan McHugh', 'Jimmy Petersen']
  spec.email         = ['mchugh.r@gmail.com', 'jipe@dtu.dk']

  spec.summary       = 'Koha ILSDI integration'
  spec.description   = 'A gem for integrating with your Koha ILSDI installation'
  spec.homepage      = 'https://github.com/dtulibrary/koha_ilsdi'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock"
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'sax-machine'
end
