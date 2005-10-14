class Ingredient < ActiveRecord::Base
  belongs_to :recipe
  # Don't let the english fool you. A belongs_to :b => A has b_id
  belongs_to :food
  belongs_to :measure
end
