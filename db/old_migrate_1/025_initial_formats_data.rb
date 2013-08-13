class InitialFormatsData < ActiveRecord::Migration
  def self.up
    format_dvd = Format.create :name => "High Quality (HDTV, Burn-to-DVD, PC, Mac)",
                               :standard => "PAL",
                               :px_width => 752,
                               :px_height => 416,
                               :codec_name => "h.264"
    format_dvd.save

    format_hd = Format.create :name => "HD Quality",
                              :standard => "720p",
                              :px_width => 1280,
                              :px_height => 720,
                              :codec_name => "h.264"
    format_hd.save
 
    format_hd_plus = Format.create :name => "HD+ Quality",
                                   :standard => "1080i",
                                   :px_width => 1920,
                                   :px_height => 1080,
                                   :codec_name => "h.264"
    format_hd_plus.save

    format_portable = Format.create :name => "Portable Quality (Portable Video Players)",
                                    :standard => "mpeg",
                                    :px_width => 320,
                                    :px_height => 176,
                                    :codec_name => "mpeg4"
    format_portable.save

    format_mobile = Format.create :name => "Mobile Quality",
                                  :standard => "mpeg",
                                  :px_width => 208,
                                  :px_height => 112,
                                  :codec_name => "mpeg4"
    format_mobile.save
    
    price_class_a = PriceClass.create :name => "Clip HD",
                                      :price_gbp => 4.50,
                                      :price_usd => 8.99,
                                      :price_eur => 8.99
    price_class_a.save

    price_class_b = PriceClass.create :name => "Clip DVD",
                                      :price_gbp => 3.50,
                                      :price_usd => 2.99,
                                      :price_eur => 2.99
    price_class_b.save

    price_class_c = PriceClass.create :name => "Clip Portable",
                                      :price_gbp => 1.50,
                                      :price_usd => 0.99,
                                      :price_eur => 0.99
    price_class_c.save

    price_class_d = PriceClass.create :name => "Clip Mobile",
                                      :price_gbp => 1.50,
                                      :price_usd => 0.99,
                                      :price_eur => 0.99
    price_class_d.save

    price_class_e = PriceClass.create :name => "Episode HD",
                                      :price_gbp => 10.50,
                                      :price_usd => 6.99,
                                      :price_eur => 6.99
    price_class_e.save

    price_class_f = PriceClass.create :name => "Episode DVD",
                                      :price_gbp => 8.50,
                                      :price_usd => 4.99,
                                      :price_eur => 4.99
    price_class_f.save

    price_class_g = PriceClass.create :name => "Episode Portable",
                                      :price_gbp => 6.50,
                                      :price_usd => 3.99,
                                      :price_eur => 3.99
    price_class_g.save

    price_class_h = PriceClass.create :name => "Episode Mobile",
                                      :price_gbp => 4.50,
                                      :price_usd => 2.99,
                                      :price_eur => 2.99
    price_class_h.save
    
  end

  def self.down
  end
end
