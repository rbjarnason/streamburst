class PriceClassesController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @price_class_pages, @price_classes = paginate :price_classes, :per_page => 20
  end

  def show
    @price_class = PriceClass.find(params[:id])
  end

  def new
    @price_class = PriceClass.new
  end

  def create
    @price_class = PriceClass.new(params[:price_class])
    if @price_class.save
      flash[:notice] = 'PriceClass was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @price_class = PriceClass.find(params[:id])
  end

  def update
    @price_class = PriceClass.find(params[:id])
    if @price_class.update_attributes(params[:price_class])
      flash[:notice] = 'PriceClass was successfully updated.'
      redirect_to :action => 'show', :id => @price_class
    else
      render :action => 'edit'
    end
  end

  def destroy
    PriceClass.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
