class Ingredient < ActiveRecord::Base
  belongs_to :recipe
  has_one :food
  has_one :measure
end
