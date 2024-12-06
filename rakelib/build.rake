# frozen-string-literal: true

GRAMMAR_FILE = 'syntax/mvinl.y'
COMPILED_FILE = 'syntax/mvinl.tab.rb'

task 'build' do
  system('racc', GRAMMAR_FILE, '-o', COMPILED_FILE)
end
