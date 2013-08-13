class Tag < ActiveRecord::Base
  has_and_belongs_to_many :bids, :order => "bids.bid_amount DESC", :limit => 10 do
    def only_active_in_territory(territory_id)
      logger.debug("TERRID=#{territory_id}")
      find :all, :conditions => "active = 1 AND territory_id = #{territory_id}"
    end
  end
end
