class Localist

  # Keep all configuration defined by user
  def self.localist_config
    @localist_config ||= Hash.new()
  end

  # Return the list of the locales supported by your application.
  def self.supported_locales
    localist_config[:supported_locales] || []
  end

  # Set the list of the locales supported by your application.
  # Usage example:
  #   Localist.supported_locales = %w[ en-US pt-BR es-ES fr-FR]
  def self.supported_locales= locales
    raise "You have a invalid locale on %s. Fix it before use the plugin" % locales unless valid?(locales)
    setup_assets(locales)
    localist_config[:supported_locales] = locales
  end

  # Return the default locale defined by user to the application
  def self.default_locale
    localist_config[:default_locale] || supported_locales.first
  end

  # Set a default locale by application. The locale must be one of the supported locales of application.
  # Usage example:
  #   Localist.default_locale = "pt-BR"
  def self.default_locale= default
    supported?(default) or raise "The locale '#{default}' is not supported by the application."
    localist_config[:default_locale] = default  
  end

  # Return symbol used for the cookie that localist uses to maintain the locale between requests 
  # and used for the temporary param when the client manually switches the locale. 
  # The default value is <tt>:locale</tt>.
  def self.symbol
    localist_config[:symbol] ||= :locale
  end

  # Set a new symbol to be used by plugin
  # Usage example:
  #     Localist.symbol = :my_symbol
  def self.symbol= symbol
    localist_config[:symbol] = symbol
  end

  # As soon as Localist finds the best locale match (or retrieve it from the params or the cookies), 
  # it sets <tt>@localist_active_locale</tt> and calls the <tt>callback</tt>, passing it the best 
  # match as the single parameter. The callback can be a <tt>Proc</tt> or a <tT>Symbol</tt> 
  # (representing a defined method). In the callback you can set the locale of your preferred i18n 
  # plugin. If you don't set any <tt>callback</tt>, you can use the <tt>@localist_active_locale</tt> 
  # in your code however.
  def self.callback
    localist_config[:callback]
  end

  # Set some callback
  # Usage example:
  #   Localist.callback = lambda{|best_match| Locale.set(best_match)} # or :my_method_for_globalize
  def self.callback= block
    localist_config[:callback] = block
  end

  # Return the path where the flags images are.
  def self.flags_path
    File.join('localist', 'flags')
  end

  # Set this to <tt>true</tt> for strict <b>RFC2616</b> compatibility. It is <tt>false</tt> 
  # by default because strictness is useful in very special cases: change it only if you know 
  # what you are doing.
  def self.strict2616
    localist_config[:strict2616] || false
  end

  #Set strict2616 value
  def self.strict2616= value
    localist_config[:strict2616] = (value == true) ? true : false
  end

  
  def self.set(locale)
    if callback.nil?
      return
    elsif callback.kind_of?(Proc)
      callback.call(locale)
    elsif callback.kind_of?(Symbol)
      send(callback,locale)
    else
      raise "Wrong 'callback' type passed: #{Localist.callback.class}. It must be a Symbol or a Proc" 
    end
  end 
  
  # Copy the used flags locales from plugin to public/images/localist directory
  def self.setup_assets(locales)
    flags_path = File.join(RAILS_ROOT,'public', 'images', 'localist', 'flags')
    assets_path = File.join(RAILS_ROOT,'vendor', 'plugins', 'localist', 'assets')
    assets_flag_path = File.join(assets_path,'famfamfam_flag_icons', 'png')
    FileUtils.rm_rf(flags_path)
    FileUtils.makedirs(flags_path)
    flag_files = locales.map{|l| File.join(assets_flag_path,"#{country_code(l)}.png")}
    FileUtils.cp(flag_files, flags_path)
  end
  
  # Matching rules defined in RFC 2616, 
  # section 14.4: HTTP/1.1 - Header Field Definitions - Accept-Language
  # returns the best language match or nil
  def self.best_match(client_str) # something like "it-IT;q=0.3, en-EN;q=0.5, *"
    return nil if client_str.nil?
    client_str = client_str.dup
    client_locales = []
    client_accepts_any = false
    client_str.tr_s!(' ', '')
    client_str.downcase! # case insensitive match
    client_str.split(/,/).each do |tag|
      lan, q = tag.split(/;/)
      q = q.nil? ? 1 : q.sub(/q=/,'').to_f 
      if lan.eql?('*')
        client_accepts_any = true
      else
        client_locales << [ q, lan ]
      end
    end
    client_locales.sort!{|a,b| b[0] <=> a[0]}.map!{|a| a[1]}
    client_locales.each do |client_loc|
      supported_locales.each do |supported_loc|                        # client -> supported
        return supported_loc if client_loc.match(/^#{supported_loc}$/i) || # en-gb  -> en-gb
                                 supported_loc.match(/^#{client_loc}-/i) || # en     -> en-gb
                                 client_loc.match(/^#{supported_loc}-/i)    # en-gb  -> en
        unless strict2616
          match_obj = supported_loc.match(/^([^-]+)-/i)
          unless match_obj.nil?
            supp_l = match_obj.captures
            return supported_loc if client_loc.match(/^#{supp_l}-/i)       # en-us -> en-gb
          end
        end   
      end
    end
    client_accepts_any ? default_locale : nil
  end  

  protected

  # Return the country code of the locale.
  # The country code is the right side of the symbol - on locale.
  # Example:
  #   Locales: en-US pt-BR es-ES fr-FR
  #   Country Codes: US, BR, ES, FR
  def self.country_code(locale)
    locale.split('-')[1].downcase
  end
  
  # Return the language code of the locale.
  # The language code is the left side of the symbol - on locale.
  # Example:
  #   Locales: en-US pt-BR es-ES fr-FR
  #   Language Codes: en, pt, es, fr
  def self.language_code(locale)
    locale.split('-')[0]
  end
  
  # Is the locale supported?
  def self.supported?(locale)
    supported_locales.include?(locale)
  end

  def self.valid?(locale)
    if locale.kind_of?(Array)
      locale.all? do |l|
        File.exist?(File.join(RAILS_ROOT,'vendor', 'plugins', 'localist', 'assets','famfamfam_flag_icons', 'png', "#{country_code(l)}.png"))
      end
    else
      File.exist?(File.join(RAILS_ROOT,'vendor', 'plugins', 'localist', 'assets','famfamfam_flag_icons', 'png', "#{country_code(locale)}.png"))
    end
  end
  
end 
