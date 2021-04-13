# frozen_string_literal: true

require 'bundler/gem_tasks'
task default: :spec

require 'yard'
require 'nanook/version'

#
# rake yard
#
YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
  t.options += ['--title', "Nanook #{Nanook::VERSION} Documentation"]
  t.options += ['--output-dir', "docs/#{Nanook::VERSION}"]
end
