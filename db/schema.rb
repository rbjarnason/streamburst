# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101108161648) do

  create_table "activation_keys", :id => false, :force => true do |t|
    t.string   "activation_key"
    t.integer  "user_id"
    t.string   "file_name"
    t.string   "sha1_hash"
    t.string   "des_key"
    t.integer  "version"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "format_id"
    t.integer  "company_id"
    t.integer  "brand_id"
    t.integer  "order_id"
  end

  add_index "activation_keys", ["activation_key"], :name => "activation_keys_activation_key_index"

  create_table "advertisements", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "total_exposures"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
  end

  create_table "advertisements_advertisements_formats", :id => false, :force => true do |t|
    t.integer "advertisement_id"
    t.integer "advertisements_format_id"
  end

  create_table "advertisements_files", :force => true do |t|
    t.string   "file_name"
    t.string   "sha1_hash"
    t.string   "des_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "advertisements_formats", :force => true do |t|
    t.integer "advertisement_id"
    t.integer "advertisements_file_id"
    t.integer "format_id"
  end

  create_table "bids", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "territory_id"
    t.float    "bid_amount"
    t.boolean  "active"
    t.float    "today_won_amount"
    t.float    "total_won_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "advertisement_id"
  end

  create_table "bids_tags", :id => false, :force => true do |t|
    t.integer "bid_id"
    t.integer "tag_id"
  end

  create_table "brand_categories", :force => true do |t|
    t.string "name"
  end

  create_table "brand_categories_brands", :id => false, :force => true do |t|
    t.integer "brand_category_id"
    t.integer "brand_id"
  end

  create_table "brand_country_blockers", :force => true do |t|
    t.integer "brands_categories_id"
    t.string  "country_code"
  end

  create_table "brands", :force => true do |t|
    t.string  "name"
    t.integer "company_id"
    t.string  "layout_name"
    t.string  "admin_layout_name"
    t.boolean "global_brand_access"
    t.string  "video_welcome_file"
    t.string  "cart_fade_start_color"
    t.string  "cart_fade_end_color"
    t.string  "page_background_color"
    t.string  "welcome_text_color"
    t.string  "welcome_text_background_color"
    t.string  "video_trailer_file"
    t.integer "start_category_id"
    t.string  "image"
    t.string  "logo"
    t.string  "flash_trailer"
    t.string  "flash_trailer_small"
    t.text    "description"
    t.text    "email_marketing_message"
    t.integer "weight",                        :default => 0
    t.integer "help_id",                       :default => 0
    t.text    "dvm_main_help"
    t.boolean "home_enabled",                  :default => false
    t.boolean "custom_products_list",          :default => false
    t.boolean "filter_by_locale",              :default => false
    t.boolean "checkout_confirm_on_top",       :default => false
  end

  create_table "brands_categories", :force => true do |t|
    t.integer "brand_id"
    t.integer "category_id"
  end

  create_table "brands_dvm_templates", :id => false, :force => true do |t|
    t.integer "brand_id"
    t.integer "dvm_template_id"
  end

  create_table "brands_dvms", :id => false, :force => true do |t|
    t.integer "brand_id"
    t.integer "dvm_id"
  end

  create_table "brands_hosts", :id => false, :force => true do |t|
    t.integer "brand_id"
    t.integer "host_id"
  end

  create_table "campaigns", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "territory_id"
    t.integer  "advertisement_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "active"
    t.float    "max_daily_bid_amount"
    t.float    "today_total_bid_won_amount"
    t.float    "total_bid_won_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.integer "help_id"
    t.integer "weight",  :default => 0
  end

  create_table "categories_products", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "product_id"
  end

  create_table "child_products", :id => false, :force => true do |t|
    t.integer "product_id",       :null => false
    t.integer "child_product_id", :null => false
  end

  create_table "companies", :force => true do |t|
    t.string "name"
  end

  create_table "discount_vouchers", :force => true do |t|
    t.integer  "product_id"
    t.integer  "order_id"
    t.integer  "user_id"
    t.string   "token"
    t.float    "discount_gbp"
    t.float    "discount_usd"
    t.float    "discount_eur"
    t.boolean  "used",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "range_name"
    t.float    "discount_isk"
  end

  create_table "downloads", :force => true do |t|
    t.string   "file_name"
    t.string   "sha1_hash"
    t.string   "des_key"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "file_size_mb"
  end

  create_table "dvm_templates", :force => true do |t|
    t.string   "title"
    t.string   "swf_url"
    t.string   "image"
    t.string   "small_image"
    t.integer  "weight"
    t.boolean  "active"
    t.boolean  "global_brand_access"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "height"
    t.integer  "width"
    t.integer  "affiliate_percent",     :default => 5
    t.boolean  "public_access",         :default => true
    t.integer  "preview_dvm_id"
    t.string   "large_click_image"
    t.integer  "get_dvm_click_counter", :default => 0
    t.integer  "parent_product_id"
    t.string   "feed_image"
  end

  create_table "dvms", :force => true do |t|
    t.string   "name"
    t.integer  "company_id"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "exposure_count"
    t.boolean  "active"
    t.integer  "dvm_template_id"
    t.string   "comment",         :default => ""
    t.boolean  "myspace_hack",    :default => false
  end

  create_table "dvms_hosts", :id => false, :force => true do |t|
    t.integer "dvm_id"
    t.integer "host_id"
    t.boolean "active",  :default => false
  end

  create_table "formats", :force => true do |t|
    t.string   "name"
    t.string   "standard"
    t.integer  "px_width"
    t.integer  "px_height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "audio_codec"
    t.string   "video_codec"
    t.string   "text"
    t.integer  "text_width"
    t.integer  "text_height"
    t.integer  "text_pointsize"
    t.string   "text_font"
    t.integer  "text_main_pos_x"
    t.integer  "text_main_pos_y"
    t.string   "text_gaussian_value"
    t.string   "text_fill"
    t.string   "text_stroke"
    t.integer  "text_background_pos_x"
    t.integer  "text_background_pos_y"
    t.integer  "intro_total_frames"
    t.string   "intro_position"
    t.string   "pass_1_codec_options"
    t.string   "pass_2_codec_options"
    t.integer  "help_id"
    t.integer  "text_truncate_len"
    t.boolean  "text_background_enabled",    :default => false
    t.string   "pass_1_video_codec_options"
    t.string   "pass_2_video_codec_options"
    t.string   "audio_codec_options"
    t.integer  "audio_channels"
    t.float    "audio_delay"
    t.string   "avs_field_deinterlace"
    t.string   "avs_lancoz_resize"
    t.boolean  "audio_only"
    t.integer  "format_type"
  end

  create_table "heimdall_content_targets", :force => true do |t|
    t.string   "search_titles"
    t.integer  "brand_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "heimdall_possible_matches", :force => true do |t|
    t.integer  "heimdall_content_target_id"
    t.integer  "heimdall_site_target_id"
    t.datetime "first_detected_at"
    t.datetime "last_detected_at"
    t.datetime "download_started_at"
    t.integer  "detection_count"
    t.datetime "download_completed_at"
    t.datetime "published_date"
    t.string   "processing_stage"
    t.string   "title"
    t.string   "url"
    t.integer  "indicated_file_size"
    t.integer  "num_pieces"
    t.integer  "real_file_size"
    t.boolean  "multiple_files"
    t.string   "sha1"
    t.string   "md5sum"
    t.string   "description"
    t.string   "category"
    t.binary   "torrent_file"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "forensics_start_at"
    t.datetime "forensics_end_at"
  end

  create_table "heimdall_site_targets", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.string   "url_type"
    t.integer  "processing_time_interval"
    t.datetime "last_processing_time"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "heimdall_content_target_id"
  end

  add_index "heimdall_site_targets", ["url"], :name => "heimdall_site_targets_url_index", :unique => true

  create_table "helps", :force => true do |t|
    t.text   "text"
    t.string "title"
  end

  create_table "hosts", :force => true do |t|
    t.string  "name"
    t.integer "ssl_port"
  end

  add_index "hosts", ["name"], :name => "hosts_name_index"

  create_table "line_items", :force => true do |t|
    t.integer  "order_id",            :default => 0,   :null => false
    t.integer  "quantity",            :default => 0,   :null => false
    t.float    "total_price",         :default => 0.0
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "discount_voucher_id"
    t.string   "currency_code"
    t.integer  "won_bid_id"
  end

  create_table "media_watermarks", :force => true do |t|
    t.integer  "product_id",            :default => 0,     :null => false
    t.integer  "download_id",           :default => 0,     :null => false
    t.boolean  "used",                  :default => false
    t.boolean  "reserved",              :default => false
    t.integer  "user_id"
    t.integer  "line_item_id"
    t.integer  "watermark",             :default => 0,     :null => false
    t.integer  "cache_video_server_id", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cache_type",            :default => ""
    t.boolean  "has_video_watermark",   :default => false
  end

  add_index "media_watermarks", ["watermark"], :name => "audio_watermarks_watermark_index", :unique => true

  create_table "orders", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "town"
    t.string   "county"
    t.string   "postcode"
    t.string   "country"
    t.string   "card_name"
    t.string   "downloads_key"
    t.string   "status"
    t.boolean  "cancelled_by_user"
    t.boolean  "complete"
    t.string   "country_code"
    t.float    "total_price"
    t.string   "paypal_first_name"
    t.string   "paypal_last_name"
    t.string   "paypal_residence_country"
    t.string   "paypal_receiver_id"
    t.string   "paypal_payer_id"
    t.string   "paypal_payer_email"
    t.string   "paypal_verify_sign"
    t.string   "paypal_mc_currency"
    t.string   "paypal_payer_status"
    t.string   "paypal_payment_status"
    t.string   "paypal_payment_date"
    t.string   "paypal_payment_type"
    t.integer  "paypal_num_cart_items"
    t.float    "paypal_mc_gross"
    t.boolean  "sent_to_analytics"
    t.boolean  "has_audio"
    t.boolean  "has_video"
    t.string   "cache_type"
    t.string   "paypal_txn_type"
    t.string   "paypal_txn_id"
    t.string   "paypal_address_status"
    t.string   "paypal_address_name"
    t.string   "paypal_address_street"
    t.string   "paypal_address_city"
    t.string   "paypal_address_zip"
    t.string   "paypal_address_state"
    t.string   "paypal_address_country_code"
    t.string   "paypal_address_country"
    t.string   "paypal_receipt_id"
    t.integer  "paypal_invoice"
    t.float    "paypal_payment_gross"
    t.float    "paypal_payment_fee"
    t.string   "paypal_settle_currency"
    t.float    "paypal_exchange_rate"
    t.float    "paypal_settle_amount"
    t.float    "paypal_tax"
    t.float    "paypal_mc_shipping"
    t.float    "paypal_mc_fee"
    t.float    "paypal_mc_handling"
    t.string   "paypal_business"
    t.string   "paypal_receiver_email"
    t.string   "paypal_notify_version"
    t.integer  "dvm_id"
    t.string   "payflow_message"
    t.integer  "payflow_result"
    t.string   "payflow_partner"
    t.string   "payflow_correlation_id"
    t.string   "payflow_pp_ref"
    t.float    "payflow_fee_amount"
    t.string   "payflow_pn_ref"
    t.string   "payflow_vendor"
    t.string   "payflow_auth_code"
    t.string   "payflow_cv_result"
    t.boolean  "payflow_test"
    t.string   "payflow_authorization"
    t.boolean  "payflow_success"
    t.string   "payflow_fraud_review"
    t.string   "currency_code"
    t.integer  "affiliate_percent",           :default => 0
    t.string   "google_checkout_key"
    t.string   "google_order_number"
    t.string   "locale"
  end

  add_index "orders", ["google_checkout_key"], :name => "index_orders_on_google_checkout_key", :unique => true
  add_index "orders", ["google_order_number"], :name => "index_orders_on_google_order_number", :unique => true

  create_table "price_classes", :force => true do |t|
    t.string   "name"
    t.float    "price_eur",  :default => 0.0,    :null => false
    t.float    "price_gbp",  :default => 0.0,    :null => false
    t.float    "price_usd",  :default => 0.0,    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "price_isk",  :default => 2000.0
  end

  create_table "product_formats", :force => true do |t|
    t.integer  "format_id"
    t.integer  "torrent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "download_id"
  end

  create_table "product_formats_products", :id => false, :force => true do |t|
    t.integer "product_format_id"
    t.integer "product_id"
  end

  create_table "products", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "image"
    t.string   "flash_movie"
    t.string   "divx_movie"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "brand_id"
    t.boolean  "active"
    t.integer  "duration"
    t.integer  "rating"
    t.integer  "price_class_id"
    t.integer  "help_id"
    t.integer  "program_id"
    t.boolean  "discount_voucher_enabled", :default => false
    t.string   "source_format"
    t.string   "master_filename"
    t.boolean  "use_audio_watermarking",   :default => false
    t.boolean  "use_video_watermarking",   :default => false
    t.integer  "audio_watermark_gain",     :default => 0
    t.string   "watch_now_filename"
    t.boolean  "audio_only"
    t.string   "dvm_image"
    t.string   "small_image"
    t.string   "short_title"
    t.string   "flv_preview_url",          :default => ""
    t.string   "flv_preview_image",        :default => ""
    t.boolean  "parent_flag",              :default => false
    t.boolean  "direct_download",          :default => false
    t.string   "locale_filter"
    t.string   "genre",                    :default => "tvshow"
  end

  add_index "products", ["brand_id"], :name => "products_brand_id_index"

  create_table "products_tags", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "tag_id"
  end

  create_table "rights", :force => true do |t|
    t.string "name"
    t.string "controller"
    t.string "action"
  end

  create_table "rights_roles", :id => false, :force => true do |t|
    t.integer "right_id"
    t.integer "role_id"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "streamburst_config", :force => true do |t|
    t.boolean "website_open", :default => false
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "territories", :force => true do |t|
    t.string "name"
    t.string "country_codes"
  end

  create_table "torrents", :force => true do |t|
    t.binary   "torrent_data"
    t.string   "file_name"
    t.time     "length"
    t.string   "des_key"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.integer  "torrent_user_id"
    t.boolean  "admin_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.boolean  "active"
    t.string   "title"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "town"
    t.string   "county"
    t.string   "postcode"
    t.string   "country"
    t.string   "paypal_email"
    t.boolean  "dvm_affiliate",                          :default => false
    t.integer  "dvm_id"
    t.integer  "fb_user_id",                :limit => 8
    t.integer  "active_facebook_dvm_id"
    t.string   "bebo_id"
    t.integer  "active_bebo_dvm_id"
    t.boolean  "facebook_auto_deployed",                 :default => false
    t.boolean  "bebo_auto_deployed",                     :default => false
    t.string   "facebook_fb_sig_user"
    t.string   "bebo_fb_sig_user"
    t.string   "reset_password_code"
    t.datetime "reset_password_code_until"
  end

  add_index "users", ["reset_password_code"], :name => "users_reset_password_code_index", :unique => true

  create_table "video_preparation_jobs", :force => true do |t|
    t.string   "job_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "download_id"
    t.integer  "format_id"
    t.integer  "product_id"
    t.string   "downloads_key"
    t.boolean  "complete",                   :default => false, :null => false
    t.boolean  "success",                    :default => false, :null => false
    t.integer  "progress",                   :default => 0,     :null => false
    t.string   "middleman_uri",              :default => "",    :null => false
    t.datetime "completed_at"
    t.text     "preparation_args"
    t.boolean  "active"
    t.boolean  "in_progress",                :default => false
    t.boolean  "cancelled",                  :default => false
    t.boolean  "timed_out",                  :default => false
    t.boolean  "email_when_finished",        :default => false
    t.string   "error"
    t.integer  "added_to_queue_time"
    t.string   "residence_country"
    t.string   "content_store_host"
    t.integer  "order_id"
    t.boolean  "no_work_done",               :default => false
    t.integer  "file_size_mb"
    t.boolean  "sent_email",                 :default => false
    t.integer  "lock_version",               :default => 0
    t.integer  "video_server_id"
    t.integer  "estimated_preparation_time", :default => 0
    t.text     "status_text"
    t.integer  "activity_timing_type",       :default => 1
    t.integer  "start_processing_time"
    t.integer  "end_processing_time"
  end

  add_index "video_preparation_jobs", ["job_key"], :name => "video_preparation_jobs_job_key_index", :unique => true
  add_index "video_preparation_jobs", ["user_id"], :name => "video_preparation_jobs_user_id_index"

  create_table "video_preparation_jobs_video_preparation_queues", :id => false, :force => true do |t|
    t.integer "video_preparation_queue_id"
    t.integer "video_preparation_job_id"
  end

  create_table "video_preparation_queues", :force => true do |t|
    t.string  "name"
    t.boolean "active"
    t.float   "last_preparation_wait_time_per_mb", :default => 0.4
  end

  create_table "video_preparation_times", :force => true do |t|
    t.integer  "video_server_id"
    t.float    "time",            :default => 0.4
    t.integer  "activity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "video_watermarks", :force => true do |t|
    t.integer "product_id",          :default => 0,     :null => false
    t.integer "download_id",         :default => 0,     :null => false
    t.boolean "used",                :default => false
    t.boolean "reserved",            :default => false
    t.integer "user_id"
    t.integer "line_item_id"
    t.integer "watermark",           :default => 0,     :null => false
    t.string  "cache_server_prefix"
  end

  add_index "video_watermarks", ["watermark"], :name => "video_watermarks_watermark_index", :unique => true

  create_table "watermark_cache_targets", :force => true do |t|
    t.integer "download_id"
    t.integer "weight"
    t.integer "audio_watermark_gain",    :default => 0
    t.integer "max_per_cache_server",    :default => 0
    t.boolean "audio_watermark_enabled", :default => false
    t.boolean "video_watermark_enabled", :default => false
    t.string  "audio_codec"
    t.string  "cache_type",              :default => ""
  end

  create_table "won_bids", :force => true do |t|
    t.integer  "bid_id"
    t.integer  "line_item_id"
    t.float    "bid_amount"
    t.boolean  "completed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
