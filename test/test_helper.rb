require File.dirname(__FILE__)+'/../lib/neelix'

require 'test/unit'
require 'active_record'
require 'active_record/fixtures'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__)+'/fixtures/'

class Test::Unit::TestCase
  # Turn these on to use transactional fixtures with table_name(:fixture_name)
  # instantiation of fixtures
  #self.use_transactional_fixtures = true
  #self.use_instantiated_fixtures = false

  def create_fixtures(*table_names)
    Fixtures.create_fixtures(File.dirname(__FILE__)+'/fixtures/', table_names)
  end

  # more helper methods to be used by all the tests go here
end

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3',
					:dbfile => 'test/test.db')
ActiveRecord::Base.logger ||= Logger.new STDERR
