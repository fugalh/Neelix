require 'neelix'
require 'neelix/view/qt/mw.rb'
require 'neelix/view/qt/aboutdialog.rb'

# TODO
# - shelf model
# - ingredients table model editable
# - wire up QtNeelix

class IngredientTableModel < Qt::AbstractTableModel
  def initialize(r)
    super(nil)
    @recipe = r
  end

  def ingredients
    @recipe.ingredients
  end

  def recipe=(r)
    @recipe = r
    emit dataChanged(index, index)
  end

  def rowCount(parent=nil)
    ingredients.size
  end

  def columnCount(parent=nil)
    4
  end

  def data(index, role=Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole
    i = ingredients[index.row]
    return invalid if i.nil?

    v = case index.column
        when 0
          sprintf("%g",i.quantity) unless i.quantity.nil?
        when 1
          i.measure.name unless i.measure.nil?
        when 2
          i.food.name unless i.food.nil?
        when 3
          i.modifier
        end
    return Qt::Variant.new(v)
  end

  def headerData(section, orientation, role=Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole

    v = case orientation
        when Qt::Horizontal
          ["Quantity","Measure","Food","Modifier"][section]
        when Qt::Vertical
          section
        end
    return Qt::Variant.new(v)
  end

  def flags(index)
    return Qt::ItemIsEnabled unless index.isValid
    return Qt::ItemIsEditable | super(index)
  end

  def setData(index, variant, role)
    if index.isValid and role == Qt::EditRole
      s = variant.toString
      i = ingredients[index.row]
      case index.column
      when 0
        i.quantity = s.to_f
      when 1
        i.measure ||= Measure.new
        i.measure.name = s
        i.measure.save
      when 2
        i.food ||= Food.new
        i.food.name = s
        i.food.save
      when 3
        i.modifier = s
      end
      i.save

      emit dataChanged(index, index)
      return true
    else
      return false
    end
  end
end

class ShelfModel < Qt::AbstractItemModel
  # TODO
end

class QtNeelix < Qt::MainWindow
  def initialize
    super

    ## Set up the Qt Designer UI
    # see http://doc.trolltech.com/4.2/porting4-designer.html#uic-output
    @ui = Ui::MainWindow.new
    @ui.setupUi(self)

    ## Wire it up
    # see http://www.kdedevelopers.org/node/2359
    @ui.actionSave.connect(SIGNAL(:triggered), &method(:save))
    %w{recipename author tottime yields}.each do |f|
      eval "@ui.#{f}_entry.connect(SIGNAL('textChanged(const QString&)'),"+
        "&method(:#{f}_changed))" 
      eval "@ui.#{f}_entry.connect(SIGNAL(:editingFinished), &method(:save))"
    end
    @ui.directions_edit.connect(SIGNAL(:textChanged), 
                                &method(:directions_changed))
    @ui.notes_edit.connect(SIGNAL(:textChanged), &method(:notes_changed))
    @ui.actionAbout.connect(SIGNAL(:triggered), &method(:about))

    self.recipe = Recipe.find(:all).first || Recipe.new

    @ui.ingredients_table.model = IngredientTableModel.new(self.recipe)

    ObjectSpace.define_finalizer(self, proc { @recipe.save unless @recipe.nil?})
  end

  def recipename_changed(s)
    recipe.name = s
  end

  %w{author tottime yields}.each do |f|
    eval "def #{f}_changed(s); recipe.#{f} = s; end"
  end

  def directions_changed
    recipe.directions = @ui.directions_edit.to_plain_text
  end

  def notes_changed
    recipe.notes = @ui.notes_edit.to_plain_text
  end

  def recipe
    @recipe || Recipe.new
  end

  def recipe=(r)
    @recipe.save unless @recipe.nil?
    @recipe = r
    return if r.nil?
    @ui.recipename_entry.text = r.name
    @ui.author_entry.text = r.author
    @ui.tottime_entry.text = r.tottime
    @ui.yields_entry.text = r.yields
    @ui.directions_edit.text = r.directions
    @ui.notes_edit.text = r.notes
  end

  def save
    # XXX Can we save the whole db (any changed recipes)?
    recipe.save
  end

  def about
    u = Ui::AboutDialog.new
    w = Qt::Dialog.new
    u.setupUi(w)
    w.exec
  end
end
