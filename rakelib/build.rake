# frozen-string-literal: true

require 'bundler/gem_tasks'
require 'mvinl/info'

desc 'Push MVinl gem; use this task in stead of \'release\''
task push: %I[compile build release]

desc 'Compile the grammar file'
task :compile do
  system('racc', GRAMMAR_FILE, '-o', COMPILED_FILE)
end
