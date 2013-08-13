class BrandCategory < ActiveRecord::Base
  has_and_belongs_to_many :brands
end
