$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "quick_search/arclight/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "quick_search-arclight"
  s.version     = QuickSearch::Arclight::VERSION
  s.authors     = ["gwiedeman"]
  s.email       = ["gregory.wiedeman1@gmail.com"]
  s.homepage    = "https://library.albany.edu/archive"
  s.summary     = "QuickSearch::Arclight can query a separate arclight instance from quick_search."
  s.description = "QuickSearch::Arclight is a custom searcher for searching arclight."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.1"

  s.add_development_dependency "sqlite3"
end
