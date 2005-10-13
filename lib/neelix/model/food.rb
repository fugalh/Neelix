class Food < ActiveRecord::Base
  many_to_many :measures
end
