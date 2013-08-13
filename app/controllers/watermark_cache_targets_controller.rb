class WatermarkCacheTargetsController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @watermark_cache_target_pages, @watermark_cache_targets = paginate :watermark_cache_targets, :per_page => 250
  end

  def cache_status
    @watermarks = MediaWatermark.find_all_by_used(0, :conditions => "reserved = 0", :order => "cache_video_server_id ASC, download_id ASC, created_at DESC")
    @disabled_watermarks = MediaWatermark.find_all_by_used(0, :conditions => "reserved = 1", :order => "cache_video_server_id ASC, download_id ASC, created_at DESC")
  end

  def used_status
    @watermarks = MediaWatermark.find_all_by_used(1, :order => "download_id ASC, updated_at DESC")
  end

  def show
    @watermark_cache_target = WatermarkCacheTarget.find(params[:id])
  end

  def new
    @watermark_cache_target = WatermarkCacheTarget.new
    @downloads = Download.find(:all)
  end

  def create
    @watermark_cache_target = WatermarkCacheTarget.new(params[:watermark_cache_target])
    if @watermark_cache_target.save
      flash[:notice] = 'WatermarkCacheTarget was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @watermark_cache_target = WatermarkCacheTarget.find(params[:id])
    @downloads = Download.find(:all)
  end

  def update
    @watermark_cache_target = WatermarkCacheTarget.find(params[:id])
    if @watermark_cache_target.update_attributes(params[:watermark_cache_target])
      flash[:notice] = 'WatermarkCacheTarget was successfully updated.'
      redirect_to :action => 'show', :id => @watermark_cache_target
    else
      render :action => 'edit'
    end
  end

  def destroy
    WatermarkCacheTarget.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
