class BrandsCategory < ActiveRecord::Base
  has_and_belongs_to_many :brand_country_blockers

end
