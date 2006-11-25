require 'neelix'
require 'neelix/view/qt/mw.rb'
require 'neelix/view/qt/aboutdialog.rb'
require 'neelix/view/qt/ingredients.rb'
require 'neelix/view/qt/shelf.rb'

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
    @ui.shelf.model = ShelfModel.new

    # disabled for debugging
    #@ui.shelf.connect(SIGNAL('clicked(const QModelIndex&)')) do |index|
    #  r = index.internalPointer
    #  if Recipe === r
    #    self.recipe = r
    #  end
    #end

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
    @ui.ingredients_table.model ||= IngredientTableModel.new(r)
    @ui.ingredients_table.model.recipe = r
  end

  def save
    recipe.save
  end

  def about
    u = Ui::AboutDialog.new
    w = Qt::Dialog.new
    u.setupUi(w)
    w.exec
  end
end
