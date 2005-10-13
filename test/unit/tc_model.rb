require 'test_helper'

class RecipeTest < Test::Unit::TestCase
  fixtures :recipes
  def setup
    @recipe = Recipe.find(1)
  end
  def test_recipe
    assert_kind_of Recipe, @recipe
  end
end
