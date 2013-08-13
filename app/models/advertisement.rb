class Advertisement < ActiveRecord::Base
  has_and_belongs_to_many :advertisements_formats, :order => 'format_id'

  file_column :image, :magick => {:size => "550x55"}
end
