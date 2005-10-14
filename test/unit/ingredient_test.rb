require 'test_helper'

class IngredientTest < Test::Unit::TestCase
  fixtures :ingredients, :foods, :measures
  def setup
    @start = Ingredient.find(1)
  end
  def test_ingredient
    assert_kind_of Ingredient, @start
    assert_equal "Sourdough Start", @start.food.name
    assert_equal "g", @start.measure.name
    assert_equal 720.0, @start.quantity
    assert_equal "Active, 100% Hydration", @start.modifier
    assert_equal 1, @start.position
  end
end
