# nil
#   - category1
#     - recipe1
#     - recipe2
#   - category2
#     - recipe3
#
# For simplifying debugging, this is just a list of all recipes instead of a
# tree structure. The crash still happens.
class ShelfModel < Qt::AbstractItemModel
  def initialize
    super
  end

  def categories
    @categories ||= Category.find(:all)
  end

  def recipes
    @recipes ||= Recipe.find(:all)
  end

  def index(row, column, parent)
    createIndex(row, column, recipes[row])
  end

  def parent(index)
    return Qt::ModelIndex.new
  end

  def rowCount(index)
    recipes.size
  end

  def columnCount(index)
    1
  end

  def data(index, role=Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole or role == Qt::EditRole 
    return invalid unless index.isValid

    # category or recipe, the duck's the same
    o = index.internalPointer
    return invalid if o.nil?
    return Qt::Variant.new(o.name)
  end

  def setData(index, variant, role=Qt::EditRole)
    return false unless index.isValid and variant.isValid 
    return false unless role == Qt::EditRole 

    # category or recipe, the duck's the same
    o = index.internalPointer
    return false if o.nil?
    o.name = variant.toString
    o.save

    emit dataChanged(index, index)
    return true
  end

  def flags(index)
    Qt::ItemIsEditable|Qt::ItemIsEnabled|Qt::ItemIsSelectable
  end

  def headerData(section, orientation, role=Qt::DisplayRole)
    if orientation == Qt::Horizontal and role == Qt::DisplayRole
      Qt::Variant.new("Recipes")
    else
      Qt::Variant.new
    end
  end

  def hasChildren(parent)
    o = parent.internalPointer
    case o
    when Recipe
      false
    else
      true
    end
  end
end

