require 'neelix'
require 'neelix/view/qt/mw.rb'
require 'neelix/view/qt/aboutdialog.rb'

class RecipeItem < Qt::ListViewItem
  attr_accessor :recipe
  def initialize(parent,recipe)
    @recipe = recipe
    super(parent)
    # I see where they're coming from, but man I wish ruby had some kind of
    # destructor (that can see self).
    ObjectSpace.define_finalizer(self, proc { @recipe.save unless @recipe.nil?})
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
  def dispose
    @recipe = nil
    super
  end
end

class NeelixMainWindow < NeelixMainWindowBase
  def initialize(*k)
    super(*k)

    @shelf.clear
    recipes = Recipe.find(:all)
    recipes.each {|r| RecipeItem.new(@shelf,r)}
    shelf_currentChanged # is there a Qt way to do this? emit maybe?


    %w{recipename author tottime yields}.each do |i|
      eval "Qt::Object.connect(@#{i}_entry, " +
	"SIGNAL('textChanged(const QString&)'), self, " +
	"SLOT('#{i}_changed(const QString&)') )"
      eval "Qt::Object.connect(@#{i}_entry, " +
	"SIGNAL('returnPressed()'), self, " +
	"SLOT('save()') )"
    end
    %w{directions notes}.each do |i|
      eval "Qt::Object.connect(@#{i}_edit, " +
	"SIGNAL('textChanged()'), self, " +
	"SLOT('#{i}_changed()') )"
    end

    class << @ingredients_table
      def activateNextCell
	row = current_row
	col = current_column + 1
	if col > 3
	  row += 1
	  col  = 0
	end
	set_current_cell row,col
      end
    end
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
    shelf_currentChanged if @shelf.child_count <= 1
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

    @recipename_entry.text = r.name
    @author_entry.text = r.author
    @yields_entry.text = r.yields
    @tottime_entry.text = r.tottime
    
    @ingredients_table.num_rows = 0
    @ingredients_table.num_rows = r.ingredients.size+1
    r.ingredients.each_with_index do |i,j|
      @ingredients_table.set_text(j,0,i.quantity.to_s)
      @ingredients_table.set_text(j,1,
				  i.measure.nil? ? '' : i.measure.name)
      @ingredients_table.set_text(j,2,i.food.name
				  i.food.nil? ? '' : i.food.name)
      @ingredients_table.set_text(j,3,i.modifier)
    end

    @directions_edit.text = r.directions
    @notes_edit.text = r.notes

    @counterStack.enabled = true
  end

  def editAdd_Ingredient
    @ingredients_table.num_rows += 1
  end

  def delete_ingredient(row=nil)
    row = @ingredients_table.current_row if row.nil?
    @ingredients_table.remove_row(row)
    i = recipe.ingredients[row]
    recipe.ingredients.delete i unless i.nil?
  end

  def helpAbout(*)
    AboutDialog.new.exec
  end

  def shelf_item_renamed(item, i, name)
    item.recipe.name = name
    item.recipe.save
    @recipename_entry.text = item.recipe.name
  end

  def recipename_changed(name)
    recipe.name = name
    @shelf.triggerUpdate
  end

  %w{author tottime yields }.each do |i|
    eval "def #{i}_changed(s); recipe.#{i} = s; end"
  end
  %w{notes directions}.each do |i|
    eval "def #{i}_changed(); recipe.#{i} = @#{i}_edit.text; end"
  end

  def ingredient_current_changed(row,col)
    oldrow = @current_ingredient_row
    unless oldrow.nil?
      i = self.recipe.ingredients[oldrow]
      unless i.nil?
	if oldrow != row and (0..4).select {|j| 
	    t = @ingredients_table.text(oldrow,j)
	    ! (t.nil? or t.empty?)
	  }.empty?
	  delete_ingredient(oldrow)
	end
      end
    end

    @current_ingredient_row = row
  end

  def ingredient_value_changed(row,col)
    i = recipe.ingredients[row]
    if i.nil?
      i = recipe.ingredients.build(:position => row)
    end
    t = @ingredients_table.text(row,col)
    case col
    when 0 # quantity
      i.quantity = t.nil? ? nil : t.to_f
    when 1 # measure
      # TODO - reuse, duh
      i.measure = Measure.new(:name => t)
    when 2 # food
      # TODO - reuse, duh
      i.food = Food.new(:name => t)
    when 3 # modifier
      i.modifier = t
    end

    # you can never get to the end. buahahaha
    if row == @ingredients_table.numRows - 1
      @ingredients_table.numRows += 1
    end
  end

  def ingredient_row_moved(section, from, to)
    i = recipe.ingredients[from]
    if i.nil?
      puts "moving last row: TODO"
    else
      i.position = to
    end
  end

  def save
    @shelf.current_item.recipe.save
  end

  def recipe
    @shelf.current_item.recipe
  end
end
