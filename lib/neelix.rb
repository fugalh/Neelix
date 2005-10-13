require 'rubygems'
require 'active_record'

class ActiveRecord::Base
  class << self
    alias :habtm :has_and_belongs_to_many
    alias :many_to_many :has_and_belongs_to_many
  end
end
ActiveRecord::Base.logger ||= Logger.new STDERR

Dir.glob(File.dirname(__FILE__) + "/neelix/model/**/*.rb").each do |f| 
  require f 
end

