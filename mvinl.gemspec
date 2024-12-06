# frozen-string-literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mvinl/info'

GRAMMAR_FILE = 'syntax/mvinl.y'
COMPILED_FILE = 'syntax/mvinl.tab.rb'

Gem::Specification.new do |s|
  s.name          = 'mvinl'
  s.version       = MVinl::VERSION
  s.authors       = ['siery']
  s.email         = ['siery@comic.com']
  s.summary       = 'A simple configuration language made with RACC'
  s.homepage      = 'https://rubygems.org/gems/mvinl'
  s.license       = 'MIT'
  s.metadata      = { 'source_code_uri' => 'https://github.com/513ry/mvinl' }
  s.required_ruby_version = '>= 3.2.0'

  # Sify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|s|features)/}) }
  end
  # Compile syntax file
  s.files.delete(GRAMMAR_FILE)
  s.files << COMPILED_FILE
  s.require_paths = %w[lib bin s rakelib syntax]
  s.executables << 'imvnl'

  s.add_dependency 'pp', '~> 0.6.2'
end
