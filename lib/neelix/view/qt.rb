require 'neelix/view/qt/mw.rb'
require 'neelix/view/qt/aboutdialog.rb'

class RecipeItem < Qt::ListViewItem
  def initialize(parent,recipe)
    @recipe = recipe
    super(parent)
  end

  def text(col=0)
    case col
    when 0
      @recipe.name
    else
      nil
    end
  end
end

class NeelixMainWindow < NeelixMainWindowBase
  def initialize(*k)
    super(*k)

    @shelf.clear
    recipes = Recipe.find(:all)
    recipes.each {|r| RecipeItem.new(@shelf,r)}
  end


end
