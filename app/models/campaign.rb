class Campaign < ActiveRecord::Base
  has_many :bids
  belongs_to :advertisement
  belongs_to :territory
end
