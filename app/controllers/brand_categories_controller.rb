class BrandCategoriesController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @brand_category_pages, @brand_categories = paginate :brand_categories, :per_page => 100
  end

  def show
    @brand_category = BrandCategory.find(params[:id])
  end

  def new
    @brand_category = BrandCategory.new
  end

  def create
    @brand_category = BrandCategory.new(params[:brand_category])
    if @brand_category.save
      flash[:notice] = 'Brand Category was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @brand_category = BrandCategory.find(params[:id])
  end

  def update
    @brand_category = BrandCategory.find(params[:id])
    if @brand_category.update_attributes(params[:brand_category])
      flash[:notice] = 'Category was successfully updated.'
      redirect_to :action => 'show', :id => @brand_category
    else
      render :action => 'edit'
    end
  end

  def destroy
    BrandCategory.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
