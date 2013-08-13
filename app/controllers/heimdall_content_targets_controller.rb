class HeimdallContentTargetsController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @heimdall_content_target_pages, @heimdall_content_targets = paginate :heimdall_content_targets, :per_page => 100
  end

  def portal
    @heimdall_possible_matches = HeimdallPossibleMatch.find(:all, :order => "active, processing_stage, first_detected_at")
  end

  def show
    @heimdall_content_target = HeimdallContentTarget.find(params[:id])
  end

  def new
    @heimdall_content_target = HeimdallContentTarget.new
  end

  def create
    @heimdall_content_target = HeimdallContentTarget.new(params[:heimdall_content_target])
    if @heimdall_content_target.save
      flash[:notice] = 'HeimdallContentTarget was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @heimdall_content_target = HeimdallContentTarget.find(params[:id])
  end

  def update
    @heimdall_content_target = HeimdallContentTarget.find(params[:id])
    if @heimdall_content_target.update_attributes(params[:heimdall_content_target])
      flash[:notice] = 'HeimdallContentTarget was successfully updated.'
      redirect_to :action => 'show', :id => @heimdall_content_target
    else
      render :action => 'edit'
    end
  end

  def destroy
    HeimdallContentTarget.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
