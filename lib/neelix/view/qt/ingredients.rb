class IngredientTableModel < Qt::AbstractTableModel
  def initialize(r)
    @recipe = r
    super()
  end

  def ingredients
    @recipe.ingredients
  end

  def recipe=(r)
    @recipe = r
    reset
  end

  def rowCount(parent)
    ingredients.size
  end

  def columnCount(parent)
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
        else 
          raise "invalid column #{index.column}"
        end || ""
    return Qt::Variant.new(v)
  end

  def headerData(section, orientation, role=Qt::DisplayRole)
    invalid = Qt::Variant.new
    return invalid unless role == Qt::DisplayRole

    v = case orientation
        when Qt::Horizontal
          ["Quantity","Measure","Food","Modifier"][section]
        else
          section.to_s
        end
    return Qt::Variant.new(v)
  end

  def flags(index)
    return Qt::ItemIsEditable | super(index)
  end

  def setData(index, variant, role=Qt::EditRole)
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
      else
        raise "invalid column #{index.column}"
      end
      i.save

      emit dataChanged(index, index)
      return true
    else
      return false
    end
  end
end

