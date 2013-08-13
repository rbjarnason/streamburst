class Product < ActiveRecord::Base
  acts_as_taggable :normalizer => Proc.new {|name| name.downcase}

  has_and_belongs_to_many :child_products,
        :class_name => 'Product',
        :join_table => 'child_products',
        :foreign_key => 'child_product_id',
        :association_foreign_key => 'product_id'

  has_and_belongs_to_many :parent_products,
        :class_name => 'Product',
        :join_table => 'child_products',
        :foreign_key => 'product_id',
        :association_foreign_key => 'child_product_id'

  has_many :line_items
  belongs_to :line_item  
  belongs_to :brand
  belongs_to :company
  has_and_belongs_to_many :product_formats, :order => "format_id"
  has_and_belongs_to_many :categories
  belongs_to :price_class
  has_many :orders, :through => :line_items do
    def count_completed
      count :all, :conditions => "complete = 1"
    end
  end
  
  file_column :flash_movie

  file_column :image, :magick => {:versions => {
           :square => {:crop => "1:1", :size => "50x50", :name => "thumb"},
           :screen => {:crop => "4:3", :size => "640x480", :name => "screen"},
           :widescreentiny => {:crop => "16:9", :size => "80x45", :name => "widescreentiny"},
           :widgetsmall => {:size => "75x40", :name => "widgetsmall"},
           :tiny => {:crop => "16:9", :size => "75x40", :name => "tiny"},
           :widescreenthumb => {:crop => "16:9", :size => "160x90", :name => "widescreenthumb"},
           :widescreensmall => {:crop => "16:9", :size => "320x180", :name => "widescreensmall"},
           :widescreen => {:crop => "16:9", :size => "640x360", :name => "widescreen"},
         }
      }

  file_column :dvm_image, :magick => {:versions => {
           :normal => {:size => "90x160", :name => "normal"},
         }
      }

  file_column :small_image, :magick => {:versions => {
           :normal => {:size => "75x40", :name => "normal"},
         }
      }
   
  # validation stuff...
  validates_presence_of :title, :description, :image
  validates_format_of :image, 
                      :with    => %r{\.(gif|jpg|png)$}i,
                      :message => "must be a URL for a GIF, JPG, or PNG image"
  
  def self.top_ten(category_ids, brand_id, locale)
    if locale
      brand_filter = ["categories.id IN (?) AND brand_id = ? AND locale_filter = ?", category_ids, brand_id, locale]
    else
      brand_filter = ["categories.id IN (?) AND brand_id = ?", category_ids, brand_id]
    end
    products = Product.find(:all, :include=>:categories, :conditions => brand_filter)
    products_s = products.sort_by { |p| p.orders.count_completed }.reverse
    products_s[0..9]
  end

  def relative_popularity(category_id, locale)
    my_counts = self.orders.count_completed
    best_products = Product.top_ten(category_id, self.brand.id, locale)
    if my_counts == 0
      0.0
    elsif best_products.length > 0 and best_products[0].orders.count_completed > 0 and best_products[0].id == self.id
      1.0
    elsif best_products.length > 1 and best_products[1].orders.count_completed > 0
      my_counts.to_f/best_products[1].orders.count_completed.to_f
    else
      1.0
    end
  end

  def value_to_currency(value, currency_code) 
    if currency_code == "GBP" 
      "&pound;#{"%.2f" % value}"
    elsif currency_code == "EUR" 
      "&euro;#{"%.2f" % value}"
    elsif currency_code == "ISK" 
      "#{"%.0f" % value} kr."
    else 
      "$#{"%.2f" % value}"
    end 
  end

  #TODO: Make this currency stuff much more DRY
  def price_class_to_currency(currency_code)
    price = get_price(currency_code)
    value_to_currency(price, currency_code)
  end 
	 	   
  def get_price(currency_code) 
    if currency_code == "GBP" 
      self.price_class.price_gbp 
    elsif currency_code == "EUR" 
      self.price_class.price_eur 
    elsif currency_code == "ISK" 
      self.price_class.price_isk 
    else 
      self.price_class.price_usd 
    end 
  end
   
  def sponsor_price(bid_amount, currency_code)
    if currency_code == "GBP"
      [get_price(currency_code) - (bid_amount * USD_TO_GBP_CONVERSION_RATE), 0].max
    elsif currency_code == "EUR" 
      [get_price(currency_code) - (bid_amount * USD_TO_EUR_CONVERSION_RATE), 0].max
    elsif currency_code == "ISK" 
      [get_price(currency_code) - (bid_amount * USD_TO_ISK_CONVERSION_RATE), 0].max
    else 
      [get_price(currency_code) - bid_amount, 0].max
    end
  end

  def sponsor_price_to_currency(bid_amount, currency_code)
    price = sponsor_price(bid_amount, currency_code)
    value_to_currency(price, currency_code)
  end

  #TODO: Make following two methods more DRY
  #TODO: Look into what happens if two windows are open on different pages
  #TODO: What happens if one campaign has the highest bid across a lot of tags, will the other bids still show up?
  def get_best_sponsor_price_in_currency(currency_code, territory_id, session)
    begin
      raise "Missing Hash" unless session[:product_sponsor_bids] 
      if session[:product_sponsor_bids][self.id]
        sponsor_price_to_currency(session[:product_sponsor_bids][self.id][0].sponsor_bid_amount, currency_code)
      else
        sponsor_list = create_sponsor_brand_list_for_product(currency_code, territory_id, session)
        if sponsor_list.size > 0
          session[:product_sponsor_bids][self.id] = sponsor_list
          sponsor_price_to_currency(sponsor_list[0].sponsor_bid_amount, currency_code)
        else
          nil
        end
      end
    rescue
      session[:product_sponsor_bids] = Hash.new
      retry
    end
  end

  def get_sponsor_brand_list_for_product(currency_code, territory_id, session)
    begin
      raise "Missing Hash" unless session[:product_sponsor_bids] 
      if session[:product_sponsor_bids][self.id]
        session[:product_sponsor_bids][self.id]
      else
        sponsor_list = create_sponsor_brand_list_for_product(currency_code, territory_id, session)
        if sponsor_list.size > 0
          session[:product_sponsor_bids][self.id] = sponsor_list
          sponsor_list
        else
          []
        end
      end
    rescue
      session[:product_sponsor_bids] = Hash.new
      retry
    end
  end
   
  def create_sponsor_brand_list_for_product(currency_code, territory_id, session)
    @sponsor_brands = []
    for tag in self.tags
      bids = tag.bids.only_active_in_territory(territory_id)
      if bids && bids.length > 0
        for bid in bids
          sponsor_price = sponsor_price_to_currency(bid.bid_amount, currency_code)
          sponsor_discount = value_to_currency([self.get_price(currency_code) - sponsor_price(bid.bid_amount, currency_code), self.get_price(currency_code)].min, currency_code)
          sponsor_brand = SponsorBrand.new(bid.advertisement, 
                                           self.price_class_to_currency(currency_code),
                                           sponsor_discount,
                                           sponsor_price,
                                           self.id,
                                           bid.id,
                                           bid.bid_amount)
          #TODO: Optimize but don't try to delete from within the loop
          @sponsor_brands.delete_if { | brand |
                 brand.advertisement == bid.advertisement && brand.sponsor_bid_amount <= bid.bid_amount
              }

          ignore_brand = false
          for brand in @sponsor_brands
            if brand.advertisement == bid.advertisement && brand.sponsor_bid_amount > bid.bid_amount
              ignore_brand = true
              break
            end
          end

          @sponsor_brands << sponsor_brand unless ignore_brand
        end
      end
    end
    @sponsor_brands.sort {|x,y| y.sponsor_bid_amount <=> x.sponsor_bid_amount }
  end
end
