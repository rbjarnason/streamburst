class AddGenre < ActiveRecord::Migration
  def self.up
    add_column :products, :genre, :string, :default=>"tvshow"

    cat = Category.find_by_name("One Day Films")
    cat.products.each do |p|
      p.genre = "movie"
      p.save(false)
    end

    cat = Category.find_by_name("Trilogy")
    cat.products.each do |p|
      p.genre = "movie"
      p.save(false)
    end
    
    Brand.find_by_name("LazyTown").products.each do |p|
      p.genre = "kids"
      p.save(false)
    end
  end

  def self.down
  end
end
