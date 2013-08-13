class RightsController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @right_pages, @rights = paginate :rights, :per_page => 10
  end

  def show
    @right = Right.find(params[:id])
  end

  def new
    @right = Right.new
  end

  def create
    @right = Right.new(params[:right])
    if @right.save
      flash[:notice] = 'Right was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @right = Right.find(params[:id])
  end

  def update
    @right = Right.find(params[:id])
    if @right.update_attributes(params[:right])
      flash[:notice] = 'Right was successfully updated.'
      redirect_to :action => 'show', :id => @right
    else
      render :action => 'edit'
    end
  end

  def destroy
    Right.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
