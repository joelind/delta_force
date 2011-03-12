require "rubygems"
require "bundler"
Bundler.setup
require 'test/unit'
require 'shoulda'
require 'factory_girl'
require 'active_record'
require 'delta_force'

FIXTURES_PATH = File.join(File.dirname(__FILE__), 'fixtures')

ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  :database => 'delta_force_test'
)

dep = defined?(ActiveSupport::Dependencies) ? ActiveSupport::Dependencies : ::Dependencies
dep.autoload_paths.unshift FIXTURES_PATH

ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  load File.join(FIXTURES_PATH, 'schema.rb')
end

Dir[File.expand_path(File.dirname(__FILE__)) + "/factories/*.rb"].each do |file|
    require file
end

class Test::Unit::TestCase
end
