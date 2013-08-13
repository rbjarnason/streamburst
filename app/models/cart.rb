class Cart
  CART_ITEMS_PER_PAGE = 4
  
  attr_reader :items
  
  def initialize
    @items = []
  end
  
  def add_item(item)
    @items << item
  end
  
  def add_product(product, brand_id, currency_code, show_all_brands, logger)
    current_item = @items.find {|item| item.product == product}
    found_page = 0
    unless current_item
      current_item = CartItem.new(product, currency_code)
      @items << current_item
    else
      position = 0
      found_pos = 0 
      for item in @items
        position += 1 if item.product.brand.id == brand_id or show_all_brands
        if current_item == item
          found_page = (position.to_f/CART_ITEMS_PER_PAGE.to_f).ceil
          found_pos = position
        end
      end
    end
    logger.debug("position: #{found_pos} found_page: #{found_page}")
    [current_item, found_page]
  end

  def remove_product(product)
    @items.reject!{|item| item.product == product}
  end
  
  def total_items
    @items.inject(0) {|sum, item| sum + item.quantity}
  end
  
  def total_price
    @items.inject(0) {|sum, item| sum + item.price }
  end

  def total_price_for_brand(brand_id)
    sum = 0
    for item in @items
      if item.product.brand.id == brand_id
        sum += item.price
      end
    end
    return sum
  end
  
  def is_multi_brand?(brand_id)
    for li in @items
      if li.product.brand.id != brand_id
        return true
      end
    end
    return false
  end
  
  # Used in LazyTown
  def get_cart_bottom_height(brand_id, cart_items)
    linemultiplier = 0
    cart_items.each do |item|
      if item.product.title.length>27
        linemultiplier +=2
      else
        linemultiplier +=1
      end
    end
    size = 16
    if is_multi_brand?(brand_id)
      linemultiplier += 2
    end
    if self.total_items>4
      linemultiplier += 2
    end
    height = linemultiplier*size
    if self.total_items == 0
      height = 40
    else
      height += 120
    end
    height
  end
end
