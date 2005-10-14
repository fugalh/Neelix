require 'test_helper'

class MeasureTest < Test::Unit::TestCase
  fixtures :measures
  def setup
    @g = Measure.find(1)
  end
  def test_measure
    assert_kind_of Measure, @g
    assert_equal "g", @g.name
  end
end
