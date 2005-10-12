class Category < ActiveRecord::Base
  many_to_many :recipes
end
