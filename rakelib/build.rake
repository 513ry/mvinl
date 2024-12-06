# frozen-string-literal: true

require 'rubygems/package'
require 'mvinl/info'

GRAMMAR_FILE = 'syntax/mvinl.y'
COMPILED_FILE = 'syntax/mvinl.tab.rb'

gemspec = Gem::Specification.load 'mvinl.gemspec'

task push: [:build] do
  system('gem', 'push', '-v', gemspec.version, gemspec.name)
end

task install: [:build] do
  Gem.install("#{gemspec.name}-#{gemspec.version}.gem")
end

task build: [:compile] do
  Gem::Package.build(gemspec)
end

task :compile do
  system('racc', GRAMMAR_FILE, '-o', COMPILED_FILE)
end
