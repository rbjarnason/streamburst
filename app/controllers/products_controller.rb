class ProductsController < ApplicationController
  layout :store_admin_layout

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :destroy_format, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @product_pages, @products = paginate :products, :per_page => 500, :conditions => @brand_filter
  end

  def show
    @product = Product.find(params[:id], :conditions => @brand_filter)
  end

  def new
    @product = Product.new
    @brands = Brand.find(:all)
    @price_classes = PriceClass.find(:all)
    @companies = Company.find(:all)
  end

  def create
    @brands = Brand.find(:all)
    @companies = Company.find(:all)
    @price_classes = PriceClass.find(:all)
    params['product']['duration'] = params['second'].to_i + (params['minute'].to_i * 60) + (params['hour'].to_i * 60 * 60)    
    @product = Product.new(params[:product])
    if @product.save
      flash[:notice] = 'Product was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @product = Product.find(params[:id], :conditions => @brand_filter)
    @brands = Brand.find(:all)
    @companies = Company.find(:all)
    @price_classes = PriceClass.find(:all)
  end

  def update
    @brands = Brand.find(:all)
    @companies = Company.find(:all)
    @price_classes = PriceClass.find(:all)
    @product = Product.find(params[:id], :conditions => @brand_filter)
    params['product']['duration'] = params['second'].to_i + (params['minute'].to_i * 60) + (params['hour'].to_i * 60 * 60)
    if @product.update_attributes(params[:product])
      expire_fragment("product_#{@product.id}")
      flash[:notice] = 'Product was successfully updated.'
      redirect_to :action => 'show', :id => @product
    else
      render :action => 'edit'
    end
  end

  def destroy
    Product.find(params[:id], :conditions => @brand_filter).destroy
    redirect_to :action => 'list'
  end

  def manage_categories
    @product = Product.find(params[:id], :conditions => @brand_filter)
    @categories = Category.find(:all)
    if request.post?
      category = Category.find(params[:category_id])
      @product.categories << category
      if @product.save
        flash[:notice] = 'Category was successfully added.'
        redirect_to :action => 'manage_categories', :id => @product
      else
        flash[:notice] = 'There was an error when adding category'
        render :action => 'manage_categories'
      end
    end
  end

  def remove_category
    product = Product.find(params[:id], :conditions => @brand_filter)
    category = Category.find(params[:category_id])
    product.categories.delete(category)
    redirect_to :action => 'manage_categories', :id => params[:id]
  end

  def manage_childs
    @products = Product.find(:all, :conditions => "parent_flag = 0")
    @product = Product.find(params[:id])
    if request.post?
      product = Product.find(params[:product_id])
      unless @product.child_products.detect{|pr| pr.id == product.id }
        @product.child_products.push(product)
      end
      if @product.save
        flash[:notice] = 'Product child was successfully added.'
        redirect_to :action => 'manage_childs', :id => @product
      else
        flash[:notice] = 'There was an error when adding product'
        render :action => 'manage_childs'
      end
    end
  end

  def remove_child
    product = Product.find(params[:id])
    child_product = Product.find(params[:product_id])
    product.child_products.delete(child_product)
    redirect_to :action => 'manage_childs', :id => params[:id]
  end

  def manage_tags
    @product = Product.find(params[:id], :conditions => @brand_filter)
    @tags = @product.tag_names
    if request.post?
      @product.tag params[:product][:tags], :separator => ','
      debug("TAGS: #{params[:product][:tags]}")
      if @product.save
        flash[:notice] = 'Tags was successfully added.'
        redirect_to :action => 'manage_tags', :id => @product
      else
        flash[:notice] = 'There was an error when adding tags'
        render :action => 'manage_tags'
      end
    end
  end

  def remove_tag
    @product = Product.find(params[:id], :conditions => @brand_filter)
    @product.tag_remove params[:tag]
    redirect_to :action => 'manage_tags', :id => params[:id]
  end

  def manage_formats
    @product = Product.find(params[:id], :conditions => @brand_filter)
    @formats = Format.find(:all)
    @torrents = Torrent.find(:all)
    @downloads = Download.find(:all)
    if request.post?
      #TODO: Make below more DRY by passing the params to ProductFormat
      product_format = ProductFormat.new
      product_format.format_id = params[:format_id]
      if params[:torrent_id] == "nil"
        product_format.torrent_id = -1
      else
        product_format.torrent_id = params[:torrent_id]
      end
      if params[:download_id] == "nil"
        product_format.download_id = -1
      else
        product_format.download_id = params[:download_id]
      end      
      if product_format.save
        @product.product_formats << product_format
        if @product.save
          flash[:notice] = 'Product Format was successfully added.'
          redirect_to :action => 'manage_formats', :id => @product
        else
          flash[:notice] = 'Product Format save error.'
          render :action => 'manage_formats'
        end
      else
        flash[:notice] = 'Product Format save error.'
        render :action => 'manage_formats'
      end
    end 
  end

  def destroy_product_format
    @product = Product.find(params[:id], :conditions => @brand_filter)
    @product_format = ProductFormat.find(params[:product_format_id])
    @product.product_formats.delete(@product_format)
    @product_format.destroy
    redirect_to :action => 'manage_formats', :id => params[:id]
  end

end

