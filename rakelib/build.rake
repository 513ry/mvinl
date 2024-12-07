# frozen-string-literal: true

require 'rubygems/package'
require 'mvinl/info'

require 'pry'

GRAMMAR_FILE = 'syntax/mvinl.y'
COMPILED_FILE = 'syntax/mvinl.tab.rb'

gemspec = Gem::Specification.load 'mvinl.gemspec'
gemfile = "#{gemspec.name}-#{gemspec.version}.gem"

task push: [:build] do
  system('gem', 'push', "#{gemspec.name}-#{gemspec.version}.gem")
end

task install: [:build] do
  Gem.install(gemfile)
  puts "Installed #{gemfile}"
end

task build: [:compile] do
  Gem::Package.build(gemspec)
  puts "Build #{gemfile}"
end

task :compile do
  system('racc', GRAMMAR_FILE, '-o', COMPILED_FILE)
end
