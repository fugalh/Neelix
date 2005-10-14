require 'test_helper'

class FoodTest < Test::Unit::TestCase
  fixtures :foods
  def setup
    @wwf = Food.find(1)
  end
  def test_food
    assert_kind_of Food, @wwf
    assert_equal "Whole Wheat Flour", @wwf.name
  end
end
