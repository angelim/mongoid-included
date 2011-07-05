require "rubygems"
require "bundler"
Bundler.setup

require 'rspec'
require 'mongoid'
require 'mongoid-included'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
MODELS = [File.join(File.dirname(__FILE__), "models"), File.join(File.dirname(__FILE__), "models/invoice")]
MODELS.each do |_model|
  $LOAD_PATH.unshift(_model)  
end
require 'models/invoice'
require 'models/invoice/item'
require 'models/invoice/user'
require 'models/inclusion'
    
Mongoid.configure do |config|
  name = "mongoid-included-test"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
  config.autocreate_indexes = true
end

# MODELS.each do |_model|
#   Dir[ File.join(_model, "*.rb") ].sort.each { |file| require File.basename(file) }
# end

RSpec.configure do |config|
  config.mock_with :rspec
  config.after :each do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
