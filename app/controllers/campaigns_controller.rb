class CampaignsController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @campaigns_pages, @campaigns = paginate :campaigns, :per_page => 10
  end

  def show
    @campaign = Campaign.find(params[:id])
  end

  def new
    @campaign = Campaign.new
    @companies = Company.find(:all)
    #TODO: Filter ads by company
    @advertisements = Advertisement.find(:all)
    @territories = Territory.find(:all)
  end

  def create
    @campaign = Campaign.new(params[:campaign])
    if @campaign.save
      flash[:notice] = 'Campaigns was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def toggle_active
    @campaign = Campaign.find(params[:id])
    @campaign.active = !@campaign.active
    for bid in @campaign.bids
      bid.active = @campaign.active
      bid.save
    end
    @campaign.save
    list
    render :action => 'list'
  end


  def edit
    @campaign = Campaign.find(params[:id])
    @companies = Company.find(:all)
    #TODO: Filter ads by company
    @advertisements = Advertisement.find(:all)
    @territories = Territory.find(:all)
  end

  def update
    @campaign = Campaign.find(params[:id])
    if @campaign.update_attributes(params[:campaign])
      for bid in @campaign.bids
        bid.reset_from_campaign(@campaign)
      end
      flash[:notice] = 'Campaigns was successfully updated.'
      redirect_to :action => 'show', :id => @campaign
    else
      render :action => 'edit'
    end
  end

  def destroy
    Campaign.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def manage_bids
    @campaign = Campaign.find(params[:id])
    @bids = @campaign.bids
    if request.post?
      #TODO: Check if there is already another bid with same tag
      bid = Bid.new
      bid.tag params[:campaign][:tag], :separator => ','
      bid.bid_amount = params[:campaign][:bid_amount]
      if bid.reset_from_campaign(@campaign)
        flash[:notice] = 'Bid was successfully added.'
        @campaign.bids << bid
        @campaign.save
        redirect_to :action => 'manage_bids', :id => @campaign
      else
        flash[:notice] = 'There was an error when adding bids'
        render :action => 'manage_bids'
      end
    end
  end

  def update_bid
    @campaign = Campaign.find(params[:id])
    @bid = Bid.find(params[:bid_id])
    @bid.bid_amount = params[:campaign][:bid_amount]
    @bid.save
    redirect_to :action => 'manage_bids', :id => params[:id]
  end  

  def remove_bid
    @campaign = Campaign.find(params[:id])
    @bid = Bid.find(params[:bid_id])
    @bid.tag_remove @bid.tag_names[0]
    @campaign.bids.delete(@bid)
    @campaign.save
    @bid.destroy
    redirect_to :action => 'manage_bids', :id => params[:id]
  end  
end
