require 'test_helper'

class CategoryTest < Test::Unit::TestCase
  fixtures :categories, :categories_recipes, :recipes
  def setup
    @category = Category.find(1)
  end
  def test_category
    assert_kind_of Category, @category
    assert_equal "Sourdough Bread", @category.name
    assert ! @category.recipes.empty?
    assert_equal "Whole Wheat Sourdough Bread", @category.recipes.first.name
  end
end
