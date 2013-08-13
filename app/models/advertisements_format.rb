class AdvertisementsFormat < ActiveRecord::Base
  has_and_belongs_to_many :advertisements
  belongs_to :format
  belongs_to :advertisements_file
end
