class BrandsController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @brand_pages, @brands = paginate :brands, :per_page => 100
  end

  def show
    @brand = Brand.find(params[:id])
  end

  def new
    @brand = Brand.new
  end

  def create
    @brand = Brand.new(params[:brand])
    if @brand.save
      flash[:notice] = 'Brand was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @brand = Brand.find(params[:id])
  end

  def update
    @brand = Brand.find(params[:id])
    if @brand.update_attributes(params[:brand])
      flash[:notice] = 'Brand was successfully updated.'
      redirect_to :action => 'show', :id => @brand
    else
      render :action => 'edit'
    end
  end

  def destroy
    Brand.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def manage_brand_categories
    @local_brand = Brand.find(params[:id])
    @brand_categories = BrandCategory.find(:all)

    if request.post?
      brand_category = BrandCategory.find(params[:brand_category_id])
      @local_brand.brand_categories << brand_category
      if @local_brand.save
        flash[:notice] = 'Brand Category was successfully added.'
        redirect_to :action => 'manage_brand_categories', :id => @local_brand
      else
        flash[:notice] = 'There was an error when adding category'
        render :action => 'manage_brand_categories'
      end
    end
  end

  def destroy_brand_category
    product = Brand.find(params[:id])
    brand_category = BrandCategory.find(params[:brand_category_id])
    brand.brand_categories.delete(brand_category)
    redirect_to :action => 'manage_brand_categories', :id => params[:id]
  end

end
