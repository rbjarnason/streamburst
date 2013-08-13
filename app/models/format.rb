class Format < ActiveRecord::Base
  has_many :product_formats, :order => "format_type"
end
