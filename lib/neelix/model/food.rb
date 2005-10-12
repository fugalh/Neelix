class Food < ActiveRecord::Base
  belongs_to :ingredient
  many_to_many :measures
end
