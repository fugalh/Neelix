class Measure < ActiveRecord::Base
  belongs_to :ingredient
  many_to_many :foods
end
