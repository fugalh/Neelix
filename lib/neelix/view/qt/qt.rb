require 'presenter/presenter.rb'
require 'view/qt/mw.rb'
require 'view/qt/aboutdialog.rb'

class Qt::ListViewItem
  attr_accessor :data
end

class Neelix
  slots 'ingredient_moved(int,int,int)'
  
  def postinitialize(app)
    @app = app

    @counterStack.enabled = false

    @ingredients_table.rowMovingEnabled = true
    @ingredients_table.columnMovingEnabled = false
    Qt::Object.connect(
      @ingredients_table.verticalHeader, SIGNAL("indexChange(int,int,int)"), 
      self, SLOT("ingredient_moved(int,int,int)"))

    build_shelf
    @shelf.currentItem = @shelf.firstChild
    shelf_currentChanged
  end
  def build_shelf
    $replicator.cookbooks.each do |cookbook|
      i = Qt::ListViewItem.new(@shelf,cookbook.name)
      i.data = cookbook
      i.open = true
      i.setRenameEnabled(0,true)
      cookbook.categories.each do |category|
	j = Qt::ListViewItem.new(i,category.name)
	j.data = category
	j.open = true
	j.setRenameEnabled(0,true)
	category.recipes.each do |recipe|
	  k = Qt::ListViewItem.new(j,recipe.name)
	  k.data = recipe
	  k.setRenameEnabled(0,true)
	end
      end
    end
  end
  def counter_currentItem=(i)
    case i
    when Cookbook
    when Category
    when Recipe
      refresh_recipe(i)
    end
  end
  def refresh_recipe(r)
    @recipe_entry.text = r.name
    @author_entry.text = r.author
    @tottime_entry.text = r.tottime
    @yields_entry.text = r.yields

    @ingredients_table.numRows = r.ingredients.size
    r.ingredients.sort.each_with_index do |ing,j|
      @ingredients_table.setText(j,0,ing.quantity.to_s)
      @ingredients_table.setText(j,1,ing.measure.to_s)
      @ingredients_table.setText(j,2,ing.food.to_s)
      @ingredients_table.setText(j,3,ing.modifier.to_s)
    end
    adjust_columns

    @directions_edit.text = r.directions
    @note_edit.text = r.note
  end
  def adjust_columns
    @ingredients_table.numCols.times do |j|
      @ingredients_table.adjustColumn(j)
    end
  end

  # TODO
  # fileNew
  # fileOpen
  # fileSaveAs

  # exit
  def fileExit
    $qApp.quit
  end
  def editAdd_Cookbook
    c = $replicator.create('cookbook',{'name',"New Cookbook"})
    # FIXME hmm, next 4 lines are duplicate code from build_shelf. 
    # what we really want is a synctree function like in the abandoned fxruby
    # code
    i = Qt::ListViewItem.new(@shelf,c.name)
    i.data = c
    i.open = true
    i.setRenameEnabled(0,true)
    @shelf.currentItem = i
    shelf_currentChanged
    i.startRename(0)
  end
  # assumption: @shelf.currentItem.data === Cookbook
  def editAdd_Category
    o = @shelf.currentItem.data
    a = $replicator.create('category',
      {'cookbook_id',o.id,'name',"New Category"})
    # FIXME hmm, next 4 lines are duplicate code from build_shelf. 
    # what we really want is a synctree function like in the abandoned fxruby
    # code
    i = Qt::ListViewItem.new(@shelf.currentItem,a.name)
    i.data = a
    i.open = true
    i.setRenameEnabled(0,true)
    @shelf.currentItem = i
    i.startRename(0)
  end
  # assumption: @shelf.currentItem.data === Category
  def editAdd_Recipe
    a = @shelf.currentItem.data
    r = $replicator.create('recipe', {'name',"New Recipe"})
    a.recipes << r
    # FIXME hmm, next 4 lines are duplicate code from build_shelf. 
    # what we really want is a synctree function like in the abandoned fxruby
    # code
    i = Qt::ListViewItem.new(@shelf.currentItem,r.name)
    i.data = r
    i.open = true
    i.setRenameEnabled(0,true)
    @shelf.currentItem = i
    @recipe_entry.setFocus
    @recipe_entry.selectAll
  end
  # assumption: @shelf.currentItem.data === Recipe
  def editAdd_Ingredient
    r = @shelf.currentItem.data
    m = Presenter::findCreateMeasure("")
    f = Presenter::findCreateFood("")
    i = $replicator.create('ingredient',
	{'recipe_id',r.id, 'quantity',nil, 'measure_id',m.id,
	 'food_id',f.id, 'modifier',nil})
    r.ingredients.insert(@ingredients_table.currentRow+1, i)
    r.ingredients.pop

    refresh_recipe(r)
  end
  def editDelete
    i = @shelf.currentItem
    d = i.data

    if @app.focusWidget == @ingredients_table
      return if @ingredients_table.numRows < 1
      r = d
      row = @ingredients_table.currentRow
      Presenter::deleteIngredient(r,row)
      refresh_recipe(r)
      return
    end

    case d
    when Cookbook
      Presenter::deleteCookbook(d)
    when Category
      Presenter::deleteCategory(i.parent.data, d)
    when Recipe
      Presenter::deleteRecipe(i.parent.data, d)
    end

    i.dispose
  end
  def helpAbout
    AboutDialog.new.exec
  end

  def shelf_currentChanged
    if not @shelf.currentItem
      @counterStack.enabled = false
      @editAdd_CookbookAction.enabled = true
      @editAdd_CategoryAction.enabled = false
      @editAdd_RecipeAction.enabled = false
      @editAdd_IngredientAction.enabled = false
      @editDeleteAction.enabled = false
      return
    end

    i = @shelf.currentItem.data
    self.counter_currentItem = i

    # counterStack enabled or disabled?
    # enable/disable menu items
    case i
    when Cookbook
      @counterStack.enabled = false

      @editAdd_CookbookAction.enabled = true
      @editAdd_CategoryAction.enabled = true
      @editAdd_RecipeAction.enabled = false
      @editAdd_IngredientAction.enabled = false
      @editDeleteAction.enabled = true
    when Category
      @counterStack.enabled = false

      @editAdd_CookbookAction.enabled = true
      @editAdd_CategoryAction.enabled = false
      @editAdd_RecipeAction.enabled = true
      @editAdd_IngredientAction.enabled = false
      @editDeleteAction.enabled = true
    when Recipe
      @counterStack.enabled = true

      @editAdd_CookbookAction.enabled = true
      @editAdd_CategoryAction.enabled = false
      @editAdd_RecipeAction.enabled = false
      @editAdd_IngredientAction.enabled = true
      @editDeleteAction.enabled = true
    else
      @counterStack.enabled = false

      @editAdd_CookbookAction.enabled = true
      @editAdd_CategoryAction.enabled = false
      @editAdd_RecipeAction.enabled = false
      @editAdd_IngredientAction.enabled = false
      @editDeleteAction.enabled = false
    end
  end
  def shelf_item_renamed(item,col,text)
    data = item.data
    data.name = text

    case data
    when Recipe
      @recipe_entry.text = text
    end
  end

  # assumption: @shelf.currentItem.data === Recipe
  def ingredient_moved(section,fromIndex,toIndex)
    r = @shelf.currentItem.data

    toIndex -= 1 if fromIndex < toIndex
    r.ingredients.insert(toIndex, r.ingredients.delete_at(fromIndex))
  end

  def recipename_changed(text)
    @shelf.currentItem.data.name = text
    @shelf.currentItem.setText(0,text)
  end
  def author_changed(text)
    @shelf.currentItem.data.author = text
  end
  def tottime_changed(text)
    @shelf.currentItem.data.tottime = text
  end
  def yields_changed(text)
    @shelf.currentItem.data.yields = text
  end
  def ingredient_changed(row,col)
    recipe = @shelf.currentItem.data
    text = @ingredients_table.text(row,col)
    case col
    when 0  # quantity
      recipe.ingredients.sort[row].quantity = text
    when 1  # measure
      recipe.ingredients.sort[row].measure = Presenter::findCreateMeasure(text)
    when 2  # food
      recipe.ingredients.sort[row].food = Presenter::findCreateFood(text)
    when 3  # modifier
      recipe.ingredients.sort[row].modifier = text
    end
    adjust_columns
    refresh_recipe(recipe)
  end
  def directions_changed()
    @shelf.currentItem.data.directions = @directions_edit.text
  end
  def note_changed()
    @shelf.currentItem.data.note = @note_edit.text
  end
end

a = Qt::Application.new(ARGV)
w = Neelix.new
w.postinitialize(a)
w.resize(800,600)

# run
a.mainWidget = w
w.show
a.exec

# vim:fdm=syntax
