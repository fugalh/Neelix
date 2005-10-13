class Measure < ActiveRecord::Base
  many_to_many :foods
end
