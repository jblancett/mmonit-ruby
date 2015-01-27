# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "mmonit/version"

Gem::Specification.new do |gem|
	gem.authors = ['Josh Blancett']
	gem.email = ['joshblancett@gmail.com']
	gem.homepage = 'http://github.com/jblancett/mmonit-ruby'
	gem.summary = 'Ruby interface to M/Monit'
	gem.description = gem.summary
	gem.name = 'mmonit'
	gem.files = Dir.glob("{bin,lib}/**/*") + %w(README.md)
	gem.require_paths = ['lib']
	gem.version = MMonit::VERSION
end
