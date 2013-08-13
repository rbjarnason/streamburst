#module TMail
#
#  class HeaderField   # redefine
#
#    FNAME_TO_CLASS = {
#      'date'                      => DateTimeHeader,
#      'resent-date'               => DateTimeHeader,
#      'to'                        => AddressHeader,
#      'cc'                        => AddressHeader,
#      'bcc'                       => AddressHeader,
#      'from'                      => AddressHeader,
#      'reply-to'                  => AddressHeader,
#      'resent-to'                 => AddressHeader,
#      'resent-cc'                 => AddressHeader,
#      'resent-bcc'                => AddressHeader,
#      'resent-from'               => AddressHeader,
#      'resent-reply-to'           => AddressHeader,
#      'sender'                    => SingleAddressHeader,
#      'resent-sender'             => SingleAddressHeader,
#      'return-path'               => ReturnPathHeader,
#      'message-id'                => MessageIdHeader,
#      'resent-message-id'         => MessageIdHeader,
#      'in-reply-to'               => ReferencesHeader,
#      'received'                  => ReceivedHeader,
#      'references'                => ReferencesHeader,
#      'keywords'                  => KeywordsHeader,
#      'encrypted'                 => EncryptedHeader,
#      'mime-version'              => MimeVersionHeader,
#      'content-type'              => ContentTypeHeader,
#      'content-transfer-encoding' => ContentTransferEncodingHeader,
#      'content-disposition'       => ContentDispositionHeader,
#    # modified by mdh
#      'content-id'                => UnstructuredHeader,
#      'subject'                   => UnstructuredHeader,
#      'comments'                  => UnstructuredHeader,
#      'content-description'       => UnstructuredHeader
#    }
#
#  end
#
#  class Mail
#    # added by mdh
#    def set_content_id( str, params = nil )
#      if h = @header['content-id']
#        h.content_id = str
#        h.params.clear
#      else
#        store('Content-Id', str)
#        h = @header['content-id']
#      end
#      h.params.replace params if params
#    end
#  end
#
#end # end TMail module
#
#module ActionMailer
#
#  class Part
#
#    # added by mdh
#    # The content id of the part.
#    adv_attr_accessor :content_id
#
#    # Create a new part from the given +params+ hash. The valid params keys
#    # correspond to the accessors.
#    def initialize(params)
#      @content_type = params[:content_type]
#      # added by mdh
#      @content_id = params[:content_id]
#      @content_disposition = params[:disposition] || "inline"
#      @charset = params[:charset]
#      @body = params[:body]
#      @filename = params[:filename]
#      @transfer_encoding = params[:transfer_encoding] || "quoted-printable"
#      @headers = params[:headers] || {}
#      @parts = []
#    end
#
#    # Convert the part to a mail object which can be included in the parts
#    # list of another mail object.
#    def to_mail(defaults)
#      part = TMail::Mail.new
#
#      real_content_type, ctype_attrs = parse_content_type(defaults)
#
#      if @parts.empty?
#        part.content_transfer_encoding = transfer_encoding || "quoted-printable"
#        case (transfer_encoding || "").downcase
#          when "base64" then
#            part.body = TMail::Base64.folding_encode(body)
#          when "quoted-printable"
#            part.body = [Utils.normalize_new_lines(body)].pack("M*")
#          else
#            part.body = body
#        end
#
#        # Always set the content_type after setting the body and or parts!
#        # Also don't set filename and name when there is none (like in
#        # non-attachment parts)
#        if content_disposition == "attachment"
#          ctype_attrs.delete "charset"
#          part.set_content_type(real_content_type, nil,
#            squish("name" => filename).merge(ctype_attrs))
#          part.set_content_disposition(content_disposition,
#            squish("filename" => filename).merge(ctype_attrs))
#        else
#          part.set_content_type(real_content_type, nil, ctype_attrs)
#          part.set_content_disposition(content_disposition)
#        end
#        # added by mdh
#        part.set_content_id(content_id)
#      else
#        if String === body
#          part = TMail::Mail.new
#          part.body = body
#          part.set_content_type(real_content_type, nil, ctype_attrs)
#          part.set_content_disposition "inline"
#          m.parts << part
#        end
#
#        @parts.each do |p|
#          prt = (TMail::Mail === p ? p : p.to_mail(defaults))
#          part.parts << prt
#        end
#
#        part.set_content_type(real_content_type, nil, ctype_attrs) if real_content_type =~ /multipart/
#      end
#
#      headers.each { |k,v| part[k] = v }
#      part
#
#    end
#
#  end
#
#  class Base
#
#    # Specify the content id for the message.
#    adv_attr_accessor :content_id
#
#    # Initialize the mailer via the given +method_name+. The body will be
#    # rendered and a new TMail::Mail object created.
#    def create!(method_name, *parameters) #:nodoc:
#      initialize_defaults(method_name)
#      send(method_name, *parameters)
#
#      # If an explicit, textual body has not been set, we check assumptions.
#      unless String === @body
#        # First, we look to see if there are any likely templates that match,
#        # which include the content-type in their file name (i.e.,
#        # "the_template_file.text.html.rhtml", etc.). Only do this if parts
#        # have not already been specified manually.
#        if @parts.empty?
#          templates = Dir.glob("#{template_path}/#{@template}.*")
#          templates.each do |path|
#            # TODO: don't hardcode rhtml|rxml
#            basename = File.basename(path)
#            next unless md = /^([^\.]+)\.([^\.]+\.[^\+]+)\.(rhtml|rxml)$/.match(basename)
#            template_name = basename
#            content_type = md.captures[1].gsub('.', '/')
#            @parts << Part.new(:content_type => content_type,
#              # added by mdh
#              :content_id => "" || content_id,
#              :disposition => "inline", :charset => charset,
#              :body => render_message(template_name, @body))
#          end
#          unless @parts.empty?
#            @content_type = "multipart/alternative"
#            @parts = sort_parts(@parts, @implicit_parts_order)
#          end
#        end
#
#        # Then, if there were such templates, we check to see if we ought to
#        # also render a "normal" template (without the content type). If a
#        # normal template exists (or if there were no implicit parts) we render
#        # it.
#        template_exists = @parts.empty?
#        template_exists ||= Dir.glob("#{template_path}/#{@template}.*").any? { |i| File.basename(i).split(".").length == 2 }
#        @body = render_message(@template, @body) if template_exists
#
#        # Finally, if there are other message parts and a textual body exists,
#        # we shift it onto the front of the parts and set the body to nil (so
#        # that create_mail doesn't try to render it in addition to the parts).
#        if !@parts.empty? && String === @body
#          @parts.unshift Part.new(:charset => charset, :body => @body)
#          @body = nil
#        end
#      end
#
#      # If this is a multipart e-mail add the mime_version if it is not
#      # already set.
#      @mime_version ||= "1.0" if !@parts.empty?
#
#      # build the mail object itself
#      @mail = create_mail
#    end
#
#  end
#end