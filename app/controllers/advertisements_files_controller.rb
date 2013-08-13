class AdvertisementsFilesController < ApplicationController
  layout :store_admin_layout
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @advertisements_file_pages, @advertisements_files = paginate :advertisements_files, :per_page => 10
  end

  def show
    @advertisements_file = AdvertisementsFile.find(params[:id])
  end

  def new
    @advertisements_file = AdvertisementsFile.new
  end

  def create
    @advertisements_file = AdvertisementsFile.new(params[:advertisements_file])
    if @advertisements_file.save
      flash[:notice] = 'AdvertisementsFile was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @advertisements_file = AdvertisementsFile.find(params[:id])
  end

  def update
    @advertisements_file = AdvertisementsFile.find(params[:id])
    if @advertisements_file.update_attributes(params[:advertisements_file])
      flash[:notice] = 'AdvertisementsFile was successfully updated.'
      redirect_to :action => 'show', :id => @advertisements_file
    else
      render :action => 'edit'
    end
  end

  def destroy
    AdvertisementsFile.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
