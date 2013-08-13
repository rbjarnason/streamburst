class TerritoriesController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @territory_pages, @territories = paginate :territories, :per_page => 10
  end

  def show
    @territory = Territory.find(params[:id])
  end

  def new
    @territory = Territory.new
  end

  def create
    @territory = Territory.new(params[:territory])
    if @territory.save
      flash[:notice] = 'Territory was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @territory = Territory.find(params[:id])
  end

  def update
    @territory = Territory.find(params[:id])
    if @territory.update_attributes(params[:territory])
      flash[:notice] = 'Territory was successfully updated.'
      redirect_to :action => 'show', :id => @territory
    else
      render :action => 'edit'
    end
  end

  def destroy
    Territory.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
