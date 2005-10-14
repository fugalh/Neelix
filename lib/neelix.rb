require 'rubygems'
require 'active_record'

class ActiveRecord::Base
  class << self
    alias :habtm :has_and_belongs_to_many
    alias :many_to_many :has_and_belongs_to_many
  end
end
ActiveRecord::Base.logger ||= Logger.new STDERR

# require model
Dir.glob(File.dirname(__FILE__) + "/neelix/model/**/*.rb").each do |f| 
  require f 
end

class Neelix
  attr_reader :config
  def initialize
    # Get the configuration
    @config = {}
    if ENV.member?('NEELIX_UNINSTALLED')
      puts "Uninstalled..."
      prefix = File.dirname(__FILE__) + '/../'
      @config['datadir'] = prefix + '/data'
    else
      require 'rbconfig'
      @config['datadir'] = Config::CONFIG['datadir']
    end
    @config['HOME'] = ENV['HOME'] # TODO windows
    @config['confdir'] = @config['HOME']+'/.neelix/'
    system "mkdir -p #{@config['confdir']}"
  end

  def logger
    ActiveRecord::Base.logger
  end

  def open(filename)
    newdb = ! File.exist?(filename)
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
					    :dbfile => filename)
    if newdb
      ActiveRecord::Base.connection.execute(File.read(@config['datadir'] +
						      '/neelix/create.sql'))
    end
  end
end
