class Host < ActiveRecord::Base
  has_and_belongs_to_many :brands
  validates_uniqueness_of :name

end
