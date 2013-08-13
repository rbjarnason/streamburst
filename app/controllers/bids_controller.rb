class BidsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @bids_pages, @bids = paginate :bids, :per_page => 10
  end

  def show
    @bids = Bid.find(params[:id])
  end

  def new
    @bids = Bid.new
  end

  def create
    @bids = Bid.new(params[:bids])
    if @bids.save
      flash[:notice] = 'Bid was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @bids = Bid.find(params[:id])
  end

  def update
    @bids = Bid.find(params[:id])
    if @bids.update_attributes(params[:bids])
      flash[:notice] = 'Bid was successfully updated.'
      redirect_to :action => 'show', :id => @bids
    else
      render :action => 'edit'
    end
  end

  def destroy
    Bid.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
