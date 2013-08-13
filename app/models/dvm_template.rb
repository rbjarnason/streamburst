class DvmTemplate < ActiveRecord::Base
  has_and_belongs_to_many :brands

  file_column :image, :magick => {:versions => {
             :widescreenthumb => {:size => "105x350", :name => "widescreen"}
         }
      }

  file_column :feed_image, :magick => {:versions => {
             :widescreenthumb => {:size => "75x75", :name => "widescreen"}
         }
      }

  file_column :small_image, :magick => {:versions => {
             :widescreenthumb => {:size => "75x40", :name => "widescreen"}
         }
      }

  file_column :large_click_image, :magick => {:versions => {
             :widescreenthumb => {:size => "180x600", :name => "widescreen"}
         }
      }

  def get_total_order_info
    child_dvms = Dvm.find(:all, :conditions => ["dvm_template_id = ?", self.id])
    total_order_count = 0
    total_value_order_count = 0
    total_closed_order_count = 0
    total_exposures = 0
    gbp_total = 0.0
    usd_total = 0.0
    eur_total = 0.0
    gbp_affiliate_fee_total = 0.0
    usd_affiliate_fee_total = 0.0
    eur_affiliate_fee_total = 0.0

    for dvm in child_dvms
      total_exposures += dvm.exposure_count
      total_order_count += dvm.order_count
      total_value_order_count += dvm.value_order_count
      dvm_order_info = dvm.get_order_info
      total_closed_order_count += dvm_order_info[0]
      gbp_total += dvm_order_info[1]
      usd_total += dvm_order_info[2]
      eur_total += dvm_order_info[3]
      gbp_affiliate_fee_total += dvm_order_info[4]
      usd_affiliate_fee_total += dvm_order_info[5]
      eur_affiliate_fee_total += dvm_order_info[6]
    end
    [total_exposures, total_order_count, total_value_order_count, total_closed_order_count,
     gbp_total, usd_total, eur_total, gbp_affiliate_fee_total, usd_affiliate_fee_total, eur_affiliate_fee_total, child_dvms.length]
  end
  
  def total_order_info
    
  end
end
