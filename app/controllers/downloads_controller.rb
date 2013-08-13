class DownloadsController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @download_pages, @downloads = paginate :downloads, :per_page => 250
  end

  def show
    @download = Download.find(params[:id])
  end

  def new
    @download = Download.new
  end

  def create
    @download = Download.new(params[:download])
    if @download.save
      flash[:notice] = 'Download was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @download = Download.find(params[:id])
  end

  def update
    @download = Download.find(params[:id])
    if @download.update_attributes(params[:download])
      flash[:notice] = 'Download was successfully updated.'
      redirect_to :action => 'show', :id => @download
    else
      render :action => 'edit'
    end
  end

  def destroy
    Download.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
