# frozen-string-literal: true

require 'rubygems/package'
require 'mvinl/info'

require 'pry'

GRAMMAR_FILE = 'syntax/mvinl.y'
COMPILED_FILE = 'syntax/mvinl.tab.rb'
GEMSPEC = Gem::Specification.load 'mvinl.gemspec'
GEMFILE = "#{gemspec.name}-#{gemspec.version}.gem".freeze

task push: [:build] do
  system('gem', 'push', GEMFILE)
end

task install: [:build] do
  Gem.install(GEMFILE)
  puts "Installed #{GEMFILE}"
end

task build: [:compile] do
  Gem::Package.build(GEMSPEC)
  puts "Build #{GEMFILE}"
end

task :compile do
  system('racc', GRAMMAR_FILE, '-o', COMPILED_FILE)
end
