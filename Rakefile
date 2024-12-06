# frozen-string-literal: true

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec, :tag) do |t, task_args|
    t.rspec_opts = ENV['SPEC_OPTS'] || '--format documentation'
  end
  task default: :spec
rescue LoadError
  warn 'Could not run rspec'
end
