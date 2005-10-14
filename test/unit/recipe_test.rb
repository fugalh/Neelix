require 'test_helper'

class RecipeTest < Test::Unit::TestCase
  fixtures :recipes, :categories_recipes, :categories
  def setup
    @wws = Recipe.find(1)
  end
  def test_recipe
    assert_kind_of Recipe, @wws
    assert_equal "Whole Wheat Sourdough Bread", @wws.name
    assert ! @wws.categories.empty?
    assert_equal "Sourdough Bread", @wws.categories.first.name
    assert_equal "Hans Fugal", @wws.author
    assert_equal "2 loaves", @wws.yields
    assert ! @wws.directions.blank?
    assert ! @wws.notes.blank?
  end
end
