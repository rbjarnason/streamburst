class HeimdallSiteTargetsController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @heimdall_site_target_pages, @heimdall_site_targets = paginate :heimdall_site_targets, :per_page => 100
  end

  def show
    @heimdall_site_target = HeimdallSiteTarget.find(params[:id])
  end

  def new
    @heimdall_site_target = HeimdallSiteTarget.new
  end

  def create
    @heimdall_site_target = HeimdallSiteTarget.new(params[:heimdall_site_target])
    if @heimdall_site_target.save
      flash[:notice] = 'HeimdallSiteTarget was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @heimdall_site_target = HeimdallSiteTarget.find(params[:id])
  end

  def update
    @heimdall_site_target = HeimdallSiteTarget.find(params[:id])
    if @heimdall_site_target.update_attributes(params[:heimdall_site_target])
      flash[:notice] = 'HeimdallSiteTarget was successfully updated.'
      redirect_to :action => 'show', :id => @heimdall_site_target
    else
      render :action => 'edit'
    end
  end

  def destroy
    HeimdallSiteTarget.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
