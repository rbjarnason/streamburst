class Download < ActiveRecord::Base
  has_and_belongs_to_many :products
  has_and_belongs_to_many :formats
 # attr_reader :file_name
  
end
