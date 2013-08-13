#dave@streamburst.co.uk
#Str3am3urst

require 'rubygems'
require 'fastercsv'
require 'ftools'
require 'yaml'
require 'cgi'
require 'date'
#require 'vendor/plugins/PayPalSDK/lib/paypal_profile'

require 'set'
class Array
  def uniq_by
    seen = Set.new
    select{ |x| seen.add?( yield( x ) ) }
  end
end

class PayPalTransactionData
  attr_accessor :id, :timestamp, :timezone, :type, :email, :name, :transactionid, :status, :currencycode, :amt, :feeamt, :netamt
end
 
def parse_repsponse(response)
  responses = {}
  ["L_TIMESTAMP","L_TIMEZONE","L_TYPE","L_EMAIL","L_NAME","L_TRANSACTIONID","L_STATUS","L_AMT","L_CURRENCYCODE",
  "L_FEEAMT","L_NETAMT"].each do |key_search|
    response.each do |k,v|
      puts "key: #{k} value: #{v}"
      if k.include?(key_search)
        id = k[key_search.length..k.length]
        puts "id: #{id}"
        unless data = responses[id]
          data = PayPalTransactionData.new
          data.id = id
          puts "new data: #{data.inspect}"
        end
        puts "key method: #{key_search[2..key_search.length].downcase}"
        eval "data.#{key_search[2..key_search.length].downcase}=\"#{v}\""
        responses[id]=data
      end
    end
  end
  puts responses.inspect
  responses.each do |k,v|
    puts k
    puts v.inspect
  end
  puts responses.length
end
 
def setup
  # to make long names shorter for easier access and to improve readability define the following variables
    @@profile = PayPalSDKProfiles::Profile
    #unipay credentials hash
    @@email=@@profile.unipay
    # merchant credentials hash
    @@cre=@@profile.credentials
    
  #condition to check if 3 token credentials are passed
  if((@@email.nil?) && (@@cre.nil? == false))
      @@USER = @@cre["USER"]
      @@PWD = @@cre["PWD"]
      @@SIGNATURE  = @@cre["SIGNATURE"]
      @@SUBJECT = ""
  end
  #condition to check if UNIPAY credentials are passed
  if((@@cre.nil?) && (@@email.nil? == false) )
      @@USER = ""
      @@PWD = ""
      @@SIGNATURE  = ""
      @@SUBJECT = @@email["SUBJECT"]
  end
  #condition to check if 3rd party credentials are passed
  if((@@cre.nil? == false) && (@@email.nil? == false))  
      @@USER = @@cre["USER"]
      @@PWD = @@cre["PWD"]
      @@SIGNATURE  = @@cre["SIGNATURE"]
      @@SUBJECT = @@email["SUBJECT"]
  end
end

def get_input
  @today = Date.today 
  @yesterday = @today-1    
end    

def do_search(start_date, end_date)
  @caller =  PayPalSDKCallers::Caller.new(false)    
  startDate = "#{start_date.to_s}T00:00:00Z"
  endDate = "#{end_date.to_s}T24:00:00Z"     
  @transaction = @caller.call(
    { :method        => 'TransactionSearch',
      :trxtype       => 'Q',
      :startdate     => startDate,
      :enddate       => endDate,
      :transactionid => nil,
      :USER  =>  @@USER,
      :PWD   => @@PWD,
      :SIGNATURE => @@SIGNATURE,
      :SUBJECT => @@SUBJECT         
    }
  )      
  
  if @transaction.success?
    puts "Success!"
    puts @transaction.response.inspect
    parse_repsponse(@transaction.response)
  else
    puts "Error..."
    puts  @transaction.response
  end
end

def get_completed_sales
  brands = {}
  user_line_items = {}
  @order_item_count = {}
  Order.find(:all, :conditions=>["created_at > ? AND created_at < ? AND paypal_payment_status = 'Completed' AND total_price > 0.0",@start_date,@end_date]).each do |order|
    price_test = 0.0
    @order_item_count[order.id]=0
    order.line_items.each do |line_item|
      next unless line_item.total_price > 0.0
      @order_item_count[order.id]+=1
      price_test+=line_item.total_price
      unless brands[line_item.product.brand]
        brands[line_item.product.brand]=[]
      end
      unless @remove_duplicates and user_line_items["#{order.user.id}_#{line_item.product.id}"]
        brands[line_item.product.brand]<<line_item
      end
      user_line_items["#{order.user.id}_#{line_item.product.id}"] if @remove_duplicates
    end
    if order.total_price.to_s!=price_test.to_s
      raise "Order #{order.id} and lineitems do not match in price order price #{order.total_price} line_item prices #{price_test}"
    end
  end
  brands
end

def get_exchange_rate(currency_code)
  if @@currency_table[currency_code]
    @@currency_table[currency_code]
  else
    url = "http://download.finance.yahoo.com/d/quotes.csv?s=#{currency_code}GBP=X&f=l1&e=.csv"
    raw_quote_data = Net::HTTP.get(URI.parse(url))
    @@currency_table[currency_code] = raw_quote_data.strip.to_f
    puts "Exchange rate for #{currency_code} = #{@@currency_table[currency_code]}"
    @@currency_table[currency_code]
  end
end

def get_price_in_paypal_gbp_currency(item)
  exchange_rate = get_exchange_rate(item.currency_code)
  exchange_rate = exchange_rate-(exchange_rate*0.025) # Paypals 2.5% on top of the exchange rate https://www.paypal.com/cgi-bin/webscr?cmd=p/gen/fees-outside
  paypal_charge = (0.20+(item.order.total_price*0.05))/@order_item_count[item.order.id] # Paypal transaction fees
  puts "paypal_charge: #{paypal_charge} - count: #{@order_item_count[item.order.id]}"
  (item.total_price-paypal_charge)*exchange_rate
end

def create_months
  months = []
  (@start_date..@end_date).each do |day|
    months << day.strftime("%b %Y") unless months.include?(day.strftime("%b %Y"))
  end
  months
end

#Grand total: 10022.4368466974

def process_brand(brand,line_items)
  #puts brand.inspect
  #puts line_items.inspect
  rows = []
  total_revenue_before_split = 0.0
  total_revenue = 0.0
  total_sold = 0
  total_by_month_before_split = {}
  total_by_month = {}
  count_by_product = {}
  count_by_month = {}
  count_by_product_by_month = {}
  total_by_category = {}
  count_by_category = {}
  count_by_category_by_month = {}
  line_items.each do |item|
    @grand_total += price_before_split = get_price_in_paypal_gbp_currency(item)
    price = price_before_split*0.70 # 70% revenue share cut
    total_revenue_before_split += price_before_split
    total_revenue += price
    total_sold += 1

    total_by_month_before_split[item.created_at.strftime("%b %Y")] = 0.0 unless total_by_month_before_split[item.created_at.strftime("%b %Y")] 
    total_by_month_before_split[item.created_at.strftime("%b %Y")] += price_before_split 
    
    total_by_month[item.created_at.strftime("%b %Y")] = 0.0 unless total_by_month[item.created_at.strftime("%b %Y")] 
    total_by_month[item.created_at.strftime("%b %Y")] += price 
     
    count_by_product[item.product.id] = 0 unless count_by_product[item.product.id]
    count_by_product[item.product.id] += 1

    count_by_month[item.created_at.strftime("%b %Y")] = 0 unless count_by_month[item.created_at.strftime("%b %Y")]
    count_by_month[item.created_at.strftime("%b %Y")] += 1 
    
    count_by_product_by_month[item.product.id] = {} unless count_by_product_by_month[item.product.id] 
    count_by_product_by_month[item.product.id][item.created_at.strftime("%b %Y")] = 0 unless count_by_product_by_month[item.product.id][item.created_at.strftime("%b %Y")]
    count_by_product_by_month[item.product.id][item.created_at.strftime("%b %Y")] += 1 

    count_by_category_by_month[item.product.categories.first] = {} unless count_by_category_by_month[item.product.categories.first] 
    count_by_category_by_month[item.product.categories.first][item.created_at.strftime("%b %Y")] = 0 unless count_by_category_by_month[item.product.categories.first][item.created_at.strftime("%b %Y")]
    count_by_category_by_month[item.product.categories.first][item.created_at.strftime("%b %Y")] += 1

    total_by_month[item.product.categories.first] = 0.0 unless total_by_category[item.product.categories.first] 
    total_by_month[item.product.categories.first] += price

    count_by_category[item.product.categories.first] = 0  unless count_by_category[item.product.categories.first] 
    count_by_category[item.product.categories.first] += 1
  end
  line_items = line_items.uniq_by {|u| u.product.id }
  line_items_grouped = line_items.group_by {|u| u.product.categories.first }
  months = create_months
  csv_string = FasterCSV.generate do |csv|
    csv<<["Streamburst Payment Report"]
    csv<<["#{brand.name} - #{@start_date.strftime("%b %Y")} to #{@end_date.strftime("%b %Y")}"]
    csv<<[]
    csv<<["Title/Supplier", ""]+months+["Totals"]
    csv<<[]
    csv<<["Total revenue"]
    csv<<[]
    by_month = []
    months.each do |month|
      if total_by_month_before_split[month]
        by_month<<total_by_month_before_split[month].round
      else
        by_month<<0
      end
    end
    csv<<["Total revenue for #{brand.name}",""]+by_month+[total_revenue_before_split.round]
    by_month = []
    months.each do |month|
      if total_by_month[month]
        by_month<<total_by_month[month].round
      else
        by_month<<0
      end
    end
    csv<<["#{brand.name} revenue share (70%)",""]+by_month+[total_revenue.round]
    csv<<[]
    csv<<["Number of products sold"]
    csv<<[]
   # puts line_items_grouped.inspect
    line_items_grouped.each do |category,category_line_items|
      csv<<[category.name]
      category_line_items.sort_by {|i| count_by_product[i.product.id] }.reverse.each do |line_item|
        puts line_item.inspect
        by_month = []
        months.each do |month|
          if count_by_product_by_month[line_item.product.id][month]
            by_month<<count_by_product_by_month[line_item.product.id][month]
          else
            by_month<<0
          end
        end
        csv<<[line_item.product.title,""]+by_month+[count_by_product[line_item.product.id]]
      end
      csv<<[]
      by_month = []
      months.each do |month|
        by_month<<count_by_category_by_month[category][month]
      end
      csv<<["Totals products for #{category.name}",""]+by_month+[count_by_category[category]]
      csv<<[]
    end
    by_month = []
    months.each do |month|
      by_month<<count_by_month[month]
    end
    csv<<["Total products",""]+by_month+[total_sold]
  end
  filename="#{brand.name.parameterize.to_s.gsub("-","_")}_payment_report_#{@start_date.strftime("%m_%Y")}_to_#{@end_date.strftime("%m_%Y")}#{@remove_duplicates ? '_dups' : ''}.csv"
  email=SystemMailer.create_payment_report(filename,"Payment Report for #{brand.name} #{@start_date.strftime("%m %Y")} to #{@end_date.strftime("%m %Y")}",csv_string)
  SystemMailer.deliver(email) 
 # File.delete("/tmp/#{filename}")
end

namespace :accounting do
  desc "Prepare Payment Reports"
  task(:prepare_payment_reports=> :environment) do
    @@currency_table = {}
    @remove_duplicates = false
    @grand_total = 0.0
 #   @start_date = Date.parse("01/01 2010").to_time # Date.today.to_time
 #   @end_date =  Date.parse("01/01 2010").end_of_month.to_time.end_of_day #(Date.today-3.months).to_time
  
    @start_date = Date.parse("05/01 2010").to_time # Date.today.to_time
    @end_date =  Date.parse("09/01 2010").end_of_month.to_time.end_of_day
    get_completed_sales.each do |brand,line_items|
      puts "Processing: #{brand.name} £#{@grand_total}"
      process_brand(brand,line_items)
    end
    puts "Grand total: #{@grand_total}"
  end

  desc "Process Paypal Transactions"
  task(:paypal_information => :environment) do
    setup
    start_date = Date.parse("07/01")
    end_date = start_date.next
    do_search(start_date,end_date)
  end
end
