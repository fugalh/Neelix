require 'neelix/view/qt/mw.rb'
require 'neelix/view/qt/aboutdialog.rb'

class RecipeItem < Qt::ListViewItem
  attr_accessor :recipe
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
  def setText(col, text)
    super
    @recipe.name = text if col == 0
  end
end

class NeelixMainWindow < NeelixMainWindowBase
  def initialize(*k)
    super(*k)

    @shelf.clear
    recipes = Recipe.find(:all)
    recipes.each {|r| RecipeItem.new(@shelf,r)}
    shelf_currentChanged # is there a Qt way to do this? emit maybe?
  end

  def shelf_currentChanged
    item = @shelf.current_item
    if item.nil?
      self.recipe = nil
      return
    else
      self.recipe = item.recipe
    end
  end

  def editAdd_Recipe
    item = RecipeItem.new(@shelf,Recipe.new(:name => 'New Recipe'))
    @shelf.current_item = item
  end

  def delete_recipe
    item = @shelf.current_item
    r = item.recipe
    item.dispose
    r.destroy
  end

  def recipe=(r)
    if r.nil?
      @counterStack.enabled = false
      return nil
    end

    @recipe_entry.text = r.name
    @author_entry.text = r.author
    @yields_entry.text = r.yields
    @tottime_entry.text = r.tottime
    
    # TODO ingredients table

    @directions_edit.text = r.directions
    @note_edit.text = r.notes

    @counterStack.enabled = true
  end
end
