require "bundler/gem_tasks"
task :default => :spec

require 'sdoc' # sdoc https://github.com/zzak/sdoc
require 'rdoc/task'
require 'nanook/version'

#
# Note: `rake rerdoc`` forces a fresh generation of docs
#

RDoc::Task.new do |rdoc|
  rdoc.main = 'README.md' # index page
  rdoc.title = "Nanook #{Nanook::VERSION} Documentation"
  rdoc.rdoc_files.include("README.md")
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_dir = 'doc' # name of output directory
  rdoc.generator = 'sdoc' # explictly set the sdoc generator
  rdoc.template = 'rails' # template used on api.rubyonrails.org
end
