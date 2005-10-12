class Recipe < ActiveRecord::Base
  many_to_many :categories
end
