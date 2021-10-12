$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "bearpost_azul/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "bearpost_azul"
  spec.version     = BearpostAzul::VERSION
  spec.authors     = ["Lucas Kuhn"]
  spec.email       = ["lucas@nordweg.com"]
  spec.homepage    = ""
  spec.summary     = "Summary of BearpostAzul."
  spec.description = "Description of BearpostAzul."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2"

  # Bearpost Requirements
  spec.add_development_dependency "wicked_pdf"
  spec.add_development_dependency "wkhtmltopdf-binary"
  spec.add_development_dependency "listen"
  spec.add_development_dependency 'pg', '>= 0.18', '< 2.0'
  spec.add_development_dependency 'puma', '~> 5.5'
  spec.add_development_dependency 'sass-rails', '~> 5.0'
  spec.add_development_dependency 'uglifier', '>= 1.3.0'
  spec.add_development_dependency 'coffee-rails', '~> 4.2'
  spec.add_development_dependency 'turbolinks', '~> 5'
  spec.add_development_dependency 'jbuilder', '~> 2.5'
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "chunky_png"
  spec.add_development_dependency "barby"
  spec.add_development_dependency "paperclip", "~> 6.0.0"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "faraday"
  spec.add_development_dependency "faraday_middleware"
  spec.add_development_dependency "devise"
  spec.add_development_dependency "active_model_serializers"
end
