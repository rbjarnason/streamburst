class HelpsController < ApplicationController
  layout :store_admin_layout
  skip_before_filter :check_authentication, :only =>  [ :get_help, :get_offer_details ]
  skip_before_filter :check_authorization, :only =>  [ :get_help, :get_offer_details ]
 
  skip_before_filter :redirect_to_ssl, :only =>  [ :get_help, :get_offer_details ]

  class LocalizedHelp
    attr_accessor :text, :title
  end

  def get_help
#    @help = Help.find(params[:id])
    @help = LocalizedHelp.new
    @help.title = I18n.t :title, :scope => ["help_id_#{params[:id]}".to_sym]
    @help.text = I18n.t :text, :scope => ["help_id_#{params[:id]}".to_sym]
    @help.text.gsub(/%sub1/, params[:substitute]) if params[:substitute]
    info("Getting help id: #{params[:id]}")
    render :layout => false if request.xhr?
  end

  def get_offer_details
    @product = Product.find(params[:id])
    render :layout => false if request.xhr?
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @help_pages, @helps = paginate :helps, :per_page => 100
  end

  def show
    @help = Help.find(params[:id])
  end

  def new
    @help = Help.new
  end

  def create
    @help = Help.new(params[:help])
    if @help.save
      flash[:notice] = 'Help was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @help = Help.find(params[:id])
  end

  def update
    @help = Help.find(params[:id])
    if @help.update_attributes(params[:help])
      flash[:notice] = 'Help was successfully updated.'
      redirect_to :action => 'show', :id => @help
    else
      render :action => 'edit'
    end
  end

  def destroy
    Help.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
