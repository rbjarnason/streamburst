class ProductFormat < ActiveRecord::Base
  has_and_belongs_to_many :products
  belongs_to :format
  belongs_to :torrent
  belongs_to :download
end
