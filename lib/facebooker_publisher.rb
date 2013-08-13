class FacebookerPublisher < Facebooker::Rails::Publisher
  def recommend_templatized_news_feed(user, brand_name, image_url, affiliate_percent, hisher)
    send_as :templatized_action
    from(user)
    title_template "{actor} is now recommending {brand_name} downloads."
    title_data(:brand_name => brand_name)
    body_template("{actor} is now recommending and selling {brand_name} downloads from {hisher} Profile. Install the Digital Vending Machine Application and recommend {brand_name} to your friends and receive a {affiliate_percent} affiliate fee on each sold copy from your profile. Signup <a href=\"http://apps.facebook.com/dvm_app\">here.</a>")
    body_general("")
    body_data({:brand_name => brand_name, :affiliate_percent => "#{affiliate_percent}%", :hisher => "#{hisher}"})
    if image_url
      image_1(image_url)
      image_1_link("http://www.facebook.com/profile.php?id=#{user.id}")
    end
  end
end
