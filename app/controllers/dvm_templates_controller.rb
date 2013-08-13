class DvmTemplatesController < ApplicationController
  layout :store_admin_layout
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @dvm_template_pages, @dvm_templates = paginate :dvm_templates, :per_page => 100, :conditions => "active = 1"
  end

  def show
    @dvm_template = DvmTemplate.find(params[:id])
  end

  def show_top_dvms
    @top_dvms = Dvm.find(:all, :conditions => "exposure_count >= 0 and active = 1", :order => "exposure_count DESC")
  end

  def new
    @dvm_template = DvmTemplate.new
    @brands = Brand.find(:all)
    @products = Product.find(:all, :conditions => "parent_flag = 1")
  end

  def create
    @dvm_template = DvmTemplate.new(params[:dvm_template])
    if params[:set_brand_id]
      brand = Brand.find(params[:set_brand_id])
      @dvm_template.brands << brand
    end
    @dvm_template.parent_product_id = params[:parent_product_id] if params[:parent_product_id]
    if @dvm_template.save
      @dvm = Dvm.new
      @dvm.user_id = 1
      @dvm.dvm_template_id = @dvm_template.id
      @dvm.exposure_count = 0
      @dvm.active = 1
      if @dvm.save
        for brand in @dvm.dvm_template.brands
          @dvm.brands << brand
        end
      end
      @dvm_template.preview_dvm_id = @dvm.id
      @dvm_template.save
      flash[:notice] = 'DvmTemplate was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @dvm_template = DvmTemplate.find(params[:id])
    @brands = Brand.find(:all)
    @products = Product.find(:all, :conditions => "parent_flag = 1")
  end

  def update
    @dvm_template = DvmTemplate.find(params[:id])
    if params[:set_brand_id] != ""
       brand = Brand.find(params[:set_brand_id])
       @dvm_template.brands << brand unless @dvm_template.brands.include?(brand)
    end
    params[:dvm_template][:parent_product_id] = params[:parent_product_id] if params[:parent_product_id] and params[:parent_product_id] != ""
    if @dvm_template.update_attributes(params[:dvm_template])
      flash[:notice] = 'DvmTemplate was successfully updated.'
      redirect_to :action => 'show', :id => @dvm_template
    else
      render :action => 'edit'
    end
  end

  def destroy
    #DvmTemplate.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def destroy_dvm_brand
    @dvm = DvmTemplate.find(params[:id])
    @brand = Brand.find(params[:set_brand_id])
    @dvm.brands.delete(@brand)
    redirect_to :action => 'show', :id => params[:id]
  end

end

