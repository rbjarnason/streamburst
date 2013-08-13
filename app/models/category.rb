class Category < ActiveRecord::Base
  has_and_belongs_to_many :products
  has_and_belongs_to_many :brands
  
  def tname
    if I18n.locale.to_s != "en"
      Category.translate(I18n.locale.to_s, self.name)
    else
      self.name
    end
  end
  
  def self.translate(locale, text)
    if locale=="en"
      text
    elsif locale=="es"
      case text
        when "Season 1" then "Temporada 1"
        when "Season 2" then "Temporada 2"
        when "Episodes" then "Episodios"
        when "Songs" then "Canciones"
        when "Season 1 Offers" then "Ofertas T1"
        when "Season 2 Offers" then "Ofertas T2"
        when "Offers" then "Ofertas"
        when "Home" then "Inicio"
        else text
      end
    elsif locale=="is"
      case text
        when "Season 1" then "Sería 1"
        when "Season 2" then "Sería 2"
        when "Episodes" then "Þættir"
        when "Songs" then "Tónlist"
        when "Season 1 Offers" then "Sería 1 Tilboð"
        when "Season 2 Offers" then "Sería 2 Tilboð"
        when "Home" then "Heim"
        else text
      end
    elsif locale=="fr"
      case text
        when "Season 1" then "Saison 1"
        when "Season 2" then "Saison 2"
        when "Episodes" then "Episodes"
        when "Songs" then "Chansons"
        when "Season 1 Offers" then "Offres Saison 1"
        when "Season 2 Offers" then "Offres Saison 2"
        when "Offers" then "Offres"
        when "Home" then "Accueil"
        else text
      end
    end
  end
end
