# -*- encoding: utf-8 -*-

require "./lib/mmonit/version"

Gem::Specification.new do |gem|
	gem.authors = ['Josh Blancett']
	gem.email = ['joshblancett@gmail.com']
	gem.homepage = 'http://github.com/jblancett/mmonit-ruby'
	gem.summary = 'Ruby interface to M/Monit'
	gem.description = "Ruby interface for M/Monit\nAll the commands listed here are currently available:\nhttp://mmonit.com/wiki/MMonit/HTTP-API\n"
	gem.name = 'mmonit'
	gem.files = Dir["README.md", "lib/**/*"]
	gem.require_paths = ['lib']
	gem.version = MMonit::VERSION
	gem.license = 'MIT'
end
