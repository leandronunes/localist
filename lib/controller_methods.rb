module LocalistAction 
  module Controller

    def localist
      locale_from_cookie = cookies[Localist.symbol]
      locale_from_param = params.delete(Localist.symbol)
      if Localist.supported?(locale_from_param)
        cookies[Localist.symbol] = @localist_active_locale = locale_from_param
      elsif Localist.supported?(locale_from_cookie)
        @localist_active_locale = locale_from_cookie
      else
        best_match = Localist.best_match(request.env["HTTP_ACCEPT_LANGUAGE"])
        if best_match.nil? 
          if respond_to? :localist_no_match
            return localist_no_match
          else
            best_match = Localist.default_locale
          end
        end
        cookies[Localist.symbol] = @localist_active_locale = best_match
      end
      Localist.set(@localist_active_locale)
    end
        
  end # Controller
  
end 
