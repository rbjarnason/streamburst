class CGI::Session
  alias original_initialize initialize
  def initialize(cgiwrapper, option = {})
#    RAILS_DEFAULT_LOGGER.info("IN SESSION_PATCH")
    session_key = '_session_id'
    query_string = if (rpd = cgiwrapper.env_table['RAW_POST_DATA']) and rpd != ''
        rpd
      elsif (qs = cgiwrapper.env_table['QUERY_STRING']) and qs != ''
        qs
      elsif (ru = cgiwrapper.env_table['REQUEST_URI'][0..-1]).include?('?')
        ru[(ru.index('?') + 1)..-1]
      end
      if query_string and query_string.include?(session_key)        
#        RAILS_DEFAULT_LOGGER.info("IN SESSION_PATCH: #{query_string}")
        option['session_id'] = query_string.scan(/#{session_key}=(.*?)(&.*?)*$/).flatten.first
#        RAILS_DEFAULT_LOGGER.info("IN SESSION_PATCH: #{option['session_id']}")
      end
    original_initialize(cgiwrapper,option)
  end
end
