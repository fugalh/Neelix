require 'rubygems'
require 'active_record'
class ActiveRecord::Base
  class << self
    alias :habtm :has_and_belongs_to_many
    alias :many_to_many :has_and_belongs_to_many
  end
end

NEELIX_ROOT = File.dirname(__FILE__) + "/neelix"
Dir.glob(NEELIX_ROOT + "/model/**/*.rb").each { |f| require f }

