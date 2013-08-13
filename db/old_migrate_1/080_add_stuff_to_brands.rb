class AddStuffToBrands < ActiveRecord::Migration
  def self.up
   add_column :brands, :cart_fade_start_color, :string
   add_column :brands, :cart_fade_end_color, :string
   add_column :brands, :page_backround_color, :string
   add_column :brands, :welcome_text_color, :string
   add_column :brands, :welcome_text_background_color, :string
   add_column :brands, :video_trailer_file, :string

   lwr = Brand.find(2)
   lwr.cart_fade_start_color = "#FFAAAA"
   lwr.cart_fade_end_color = "#311F1F"
   lwr.page_backround_color = "#000000"
   lwr.welcome_text_color = "#D09C0A"
   lwr.welcome_text_background_color = "#000000"
   lwr.save

   rtd = Brand.find(3)
   rtd.cart_fade_start_color = "#F9B826"
   rtd.cart_fade_end_color = "#CB8D4C"
   rtd.page_backround_color = "#210303"
   rtd.welcome_text_color = "#FA770B"
   rtd.welcome_text_background_color = "#000000"
   rtd.save

   mm = Brand.find(4)
   mm.cart_fade_start_color = "#888888"
   mm.cart_fade_end_color = "#143965"
   mm.page_backround_color = "#0A243B"
   mm.welcome_text_color = "#B20104"
   mm.welcome_text_background_color = "#000000"
   mm.save

   mf = Brand.find(5)
   mf.cart_fade_start_color = "#888888"
   mf.cart_fade_end_color = "#000000"
   mf.page_backround_color = "#FFFFFF"
   mf.welcome_text_color = "#E04324"
   mf.welcome_text_background_color = "#000000"
   mf.save

  end

  def self.down
  end
end
