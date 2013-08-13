class TorrentsController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @torrent_pages, @torrents = paginate :torrents, :per_page => 10
  end

  def show
    @torrent = Torrent.find(params[:id])
  end

  def new
    @torrent = Torrent.new
  end

  def create
    setup_torrent_data
    @torrent = Torrent.new(params[:torrent])
    if @torrent.save
      flash[:notice] = 'Torrent was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @torrent = Torrent.find(params[:id])
  end

  def update
    setup_torrent_data
    @torrent = Torrent.find(params[:id])
    if @torrent.update_attributes(params[:torrent])
      flash[:notice] = 'Torrent was successfully updated.'
      redirect_to :action => 'show', :id => @torrent
    else
      render :action => 'edit'
    end
  end

  def destroy
    Torrent.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  private
  
  def setup_torrent_data
    params['torrent']['torrent_data'] = params['torrent']['tmp_file'].read
    params['torrent'].delete('tmp_file')
  end
end
