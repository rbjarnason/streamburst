class Bid < ActiveRecord::Base
  acts_as_taggable :normalizer => Proc.new {|name| name.downcase}

  has_one :campaign
  belongs_to :advertisement

  def reset_from_campaign(campaign)
    self.campaign_id = campaign.id
    self.territory_id = campaign.territory_id
    self.advertisement_id = campaign.advertisement_id
    self.active = campaign.active
    self.save
  end

  def top_bid
    tag = self.tags[0]
    bids = tag.bids if tag
    bids[0].bid_amount if bids
  end

  def sponsor_bid_amount
    if self.bid_amount > 0
      [0, self.bid_amount * SPONSOR_BID_AFTER_HANDLING_FEE_RATIO].max
    else
      0
    end
  end

  def lowest_top_ten
    tag = self.tags[0]
    bids = tag.bids if tag
    logger.debug(bids.inspect) if bids
    logger.debug("Len: #{bids.length}") if bids
    bids[bids.length-1].bid_amount if bids
  end
end
