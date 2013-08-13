class AddToFormat < ActiveRecord::Migration
  def self.up
    add_column :formats, :text, :string
    add_column :formats, :text_width, :integer
    add_column :formats, :text_height, :integer
    add_column :formats, :text_pointsize, :integer
    add_column :formats, :text_font, :string
    add_column :formats, :text_main_pos_x, :integer
    add_column :formats, :text_main_pos_y, :integer
    add_column :formats, :text_gaussian_value, :string
    add_column :formats, :text_fill, :string
    add_column :formats, :text_stroke, :string
    add_column :formats, :text_background_pos_x, :integer
    add_column :formats, :text_background_pos_y, :integer    
    add_column :formats, :intro_total_frames, :integer
    add_column :formats, :intro_position, :string
  end

  def self.down
  end
end
