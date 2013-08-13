class AdvertisementsController < ApplicationController
  layout :store_admin_layout
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @advertisements_pages, @advertisements = paginate :advertisements, :per_page => 10
  end

  def show
    @advertisement = Advertisement.find(params[:id])
  end

  def new
    @advertisement = Advertisement.new
    @companies = Company.find(:all)
  end

  def create
    @advertisement = Advertisement.new(params[:advertisement])
    if @advertisement.save
      flash[:notice] = 'Advertisement was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @advertisement = Advertisement.find(params[:id])
    @companies = Company.find(:all)
  end

  def update
    @advertisement = Advertisement.find(params[:id])
    if @advertisement.update_attributes(params[:advertisement])
      flash[:notice] = 'Advertisement was successfully updated.'
      redirect_to :action => 'show', :id => @advertisement
    else
      render :action => 'edit'
    end
  end

  def destroy
    Advertisement.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def manage_formats
    @advertisement = Advertisement.find(params[:id])
    @formats = Format.find(:all)
    @advertisements_files = AdvertisementsFile.find(:all)
    if request.post?
      #TODO: Make below more DRY by passing the params to ProductFormat
      advertisements_format = AdvertisementsFormat.new
      advertisements_format.format_id = params[:format_id]
      if params[:advertisements_file_id] == "nil"
        advertisements_format.advertisements_file_id = -1
      else
        advertisements_format.advertisements_file_id = params[:advertisements_file_id]
      end      
      if advertisements_format.save
        @advertisement.advertisements_formats << advertisements_format
        if @advertisement.save
          flash[:notice] = 'Ad Format was successfully added.'
          redirect_to :action => 'manage_formats', :id => @advertisement
        else
          flash[:notice] = 'Ad Format save error.'
          render :action => 'manage_formats'
        end
      else
        flash[:notice] = 'Ad Format save error.'
        render :action => 'manage_formats'
      end
    end
  end

  def destroy_advertisements_format
    @advertisement = Advertisement.find(params[:id])
    @advertisements_format = AdvertisementsFormat.find(params[:advertisements_format_id])
    @advertisement.advertisements_formats.delete(@advertisements_format)
    @advertisements_format.destroy
    redirect_to :action => 'manage_formats', :id => params[:id]
  end
end
