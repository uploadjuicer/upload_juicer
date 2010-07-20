require 'lib/upload_juicer'

Gem::Specification.new do |s|
  s.name        = "upload_juicer"
  s.version     = UploadJuicer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Benjamin Curtis"]
  s.email       = ["ben@uploadjuicer.com"]
  s.homepage    = "http://www.uploadjuicer.com"
  s.summary     = "UploadJuicer juices up your images!"

  s.required_rubygems_version = ">= 1.3.6"

  # If you have other dependencies, add them here
  s.add_dependency "rest-client"
  s.add_dependency "json"

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "{app}/**/*.rb", "{config}/**/*.rb", "{rails}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'
end