class PaymentDetails
  
  attr_reader :card_name

  CARD_TYPES = [
    [ "Visa",          "Visa" ],
    [ "Mastercard",    "Mastercard"   ],
    [ "Switch", "Switch" ]
  ]
  
  attr_reader :card_name, :card_type, :card_number, :card_expiry_month, :card_expiry_year, :card_begin_month, :card_begin_year, :issue_number, :security_code
  
#  validates_presence_of     :card_name, :card_type, :card_number, :card_expiry_date, :security_code, :country

#  validates_inclusion_of :card_type, :in => CARD_TYPES.map {|disp, value| value}
                            
#  validates_length_of       :card_number, 
#                            :minimum => 16,
#                            :maximum => 16,
#                            :message => "should be 16 characters long"

#  validates_length_of       :card_number, 
#                            :minimum => 3,
#                            :maximum => 3,
#                            :message => "should be 3 characters long"
  
#  validates_format_of :email,
#                      :with => /[-!#$&'*+/=?`{|}~.w]+@[a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])*(.[a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])*)+$/,
#                      :message => ' appears to be invalid'
                      
  def initialize(card_name, card_type, card_number, card_expiry_month, 
                  card_expiry_year, card_begin_month, card_begin_year, 
                  issue_number, security_code)
    @card_name = card_name
    @card_type = card_type
    @card_number = card_number
    @card_expiry_month = card_expiry_month
    @card_expiry_year = card_expiry_year
    @card_begin_month = card_begin_month
    @card_begin_year = card_begin_year
    @issue_number = issue_number
    @security_code = security_code
  end
end