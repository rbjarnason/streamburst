module CheckoutHelper
  
 def options_for_select_with_first_selected(labels,data)
   out = ""
   index=0
   labels.each do |label|
     out+="<option value=\"#{data[index]}\" #{index==0 ? "selected=\"selected\"" : ""}>#{label}</option>"
     index+=1
   end
   out
 end

def paypal_button(amount)
  if RAILS_ENV == "production" 
    request_host = "https://#{request.host}"
    paypal_path = "www.paypal.com"
    paypal_account = "dave@streamburst.co.uk"
  else
    request_host = "http://#{request.host}:3000"
    paypal_path = "www.sandbox.paypal.com"
    paypal_account = "r_bjarnason@yahoo.com"
  end

  line_items = ""
  count = 1
  for line_item in @order.line_items
    if line_item.price > 0
      line_items += "<input type=\"hidden\" name=\"item_name_#{count}\" value=\"#{line_item.product.title}\">\
      <input type=\"hidden\" name=\"amount_#{count}\" value=\"#{line_item.price}\">"
      count += 1
    end
  end
  debug(line_items)
  button = "<form action=\"https://#{paypal_path}/cgi-bin/webscr\" method=\"post\" onSubmit=\"javascript:__utmLinkPost(this)\">\
    <input type=\"hidden\" name=\"cmd\" value=\"_cart\">\
    <input type=\"hidden\" name=\"business\" value=\"#{paypal_account}\">\
    <input type=\"hidden\" name=\"no_shipping\" value=\"1\">\
    <input type=\"hidden\" name=\"upload\" value=\"1\">\
    <input type=\"hidden\" name=\"invoice\" value=\"#{@order.id}\">\
    <input type=\"hidden\" name=\"custom\" value=\"#{@order.id}\">" + line_items +
"    <input type=\"hidden\" name=\"return\" value=\"#{request_host}/checkout/paypal_complete/#{@order.id}\">\
    <input type=\"hidden\" name=\"notify_url\" value=\"#{request_host}/checkout/paypal_ipn/#{@order.id}\">\
    <input type=\"hidden\" name=\"cancel_return\" value=\"#{request_host}/checkout/paypal_cancel/#{@order.id}\">\
    <input type=\"hidden\" name=\"cpp_header_image\" value=\"#{request_host}/images/#{request.host}_paypal_banner.jpg\">\
    <input type=\"hidden\" name=\"cpp_headerback_color\" value=\"ffffff\">\
    <input type=\"hidden\" name=\"cpp_headerborder_color\" value=\"ffffff\">\
    <input type=\"hidden\" name=\"cpp_payflow_color\" value=\"ffffff\">\
    <input type=\"hidden\" name=\"cs\" value=\"ffffff\">\
    <input type=\"hidden\" name=\"no_note\" value=\"1\">\
    <INPUT TYPE=\"hidden\" name=\"charset\" value=\"utf-8\">\
    <input type=\"hidden\" name=\"currency_code\" value=\"#{@currency_code}\">\
    <input type=\"hidden\" name=\"lc\" value=\"GB\">\
    <input type=\"hidden\" name=\"bn\" value=\"PP-BuyNowBF\">\
    <input type=\"image\" src=\"#{request_host}/images/paypal_express_button_small.png\" border=\"0\" name=\"submit\" alt=\"#{t(:Make_a_payment_via_PayPal)}\">\
  </form>"
  debug(button)
  button
end
end

