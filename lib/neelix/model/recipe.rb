class Recipe < ActiveRecord::Base
  many_to_many :categories
  has_many :ingredients, :dependent => true
end
