class Brand < ActiveRecord::Base
  has_many :products
  belongs_to :company
  has_and_belongs_to_many :hosts  
  has_and_belongs_to_many :brands_dvms
  has_and_belongs_to_many :brands_dvm_templates
  has_and_belongs_to_many :brand_categories

  file_column :flash_trailer
  file_column :flash_trailer_small


  file_column :image, :magick => {:versions => {
             :widescreensmall => {:crop => "16:9", :size => "80x45", :name => "widescreensmall"},
             :widescreenthumb => {:crop => "16:9", :size => "160x90", :name => "widescreenthumb"},
             :widescreenlarge => {:size => "468x90", :name => "widescreenlarge"}
         }
      }

  def to_home_param
    "#{name.downcase.gsub(" ","_")}"
  end

end
