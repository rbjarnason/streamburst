module PaymentData
  class PaymentData

     cattr_accessor :pdt_url, :identity_token
     attr_reader :tx
     attr_accessor :params

     if RAILS_ENV == "production"
       @@pdt_url = 'https://www.paypal.com/cgi-bin/webscr'
       @@identity_token = 'wF-KICgVJbFl8fbTSUecBg17PPckyN1rIHYYdEDw0JSfTDlYkc3WBSzaD5O'
     else
       @@pdt_url = 'https://www.sandbox.paypal.com/cgi-bin/webscr'
       @@identity_token='4hDJW9edy2k7urzFMb9vulgkurdyTCCk1BQxwxj9fV3zS9ifsClABAWBu_u'
     end

     # Pass the transaction_id to the constructor. This is done in the action paypal redirects to after the payment. 
     # The value is passed in the GET variable named tx.
     # eg: pdt = Paypal::PaymentData.new(params["tx"])
     def initialize(transaction)
      empty!
      @tx = transaction
     end

     # transaction id present in the redirection from Paypal
     def triggering_transaction_id
       tx
     end

     # gives access to any returned value by Paypal
     def method_missing(m)
       if params.keys.include?(m.to_s)
         return params[m.to_s]
       end
     end

     def status
       params['payment_status']
     end

     def received_at
       Time.parse params['payment_date']
     end

     def complete?
       params['payment_status'] == "Completed"
     end

     # Transaction id Paypal returns when we issued the verification query. This is not the value passed in the return URL.
     def transaction_id
       params['txn_id']
     end

     def type
       params['txn_type']
     end

     def gross
       params['mc_gross']
     end

    def fee
      params['mc_fee']
    end

    # What currency have we been dealing with
    def currency
      params['mc_currency']
    end

    # This is the item number which we submitted to paypal 
    def item_id
      params['item_number']
    end
    # This is the invocie which you passed to paypal 
    def invoice
      params['invoice']
    end

    # This is the custom field which you passed to paypal 
    def custom
      params['custom']
    end
     
     def amount
       require 'money'
       amount = gross.sub(/[^\d]/, '').to_i
       return Money.new(amount, currency) rescue ArgumentError
       return Money.new(amount)
     end

     def empty!
      @params = {}
     end

     def parse(body)
          for line in body
                    key, value = line.scan( %r{^(\w+)\=(.*)$} ).flatten
                    params[key] = CGI.unescape(value) if key
          end
     end

     # Recontact Paypal and check we treat a valid transaction.
     def acknowledge
      uri = URI.parse(self.class.pdt_url)
      request_path = "#{uri.path}?cmd=_notify-synch&tx=#{tx}&at=#{self.class.identity_token}"
      request = Net::HTTP::Post.new(request_path)

      http = Net::HTTP.new(uri.host, uri.port)
      http.verify_mode    = OpenSSL::SSL::VERIFY_NONE unless @ssl_strict
      http.use_ssl        = true

      request = http.request(request, nil)

      result = request.body.split[0]
      raise StandardError.new("Faulty paypal result: #{request.body}") unless ["SUCCESS", "FAIL"].include?(result)
      parse(request.body)

      result == "SUCCESS" 
             
     end
  end

end
