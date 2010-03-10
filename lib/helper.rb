module LocalistAction
  module Helper
     
    # Used on view to show a menu with the available locales of application.
    def localist_menu(args={})
      menu_template = args[:template]
      menu_template ||= File.join('localist','menu') if File.exist?(File.join(RAILS_ROOT,'app','views','localist','menu.rhtml')) 

      if menu_template.nil? 
        localist_menu_html(Localist.supported_locales, @localist_active_locale, Localist.symbol)
      else
        @localist_menu = {:supported_locales => Localist.supported_locales,
                         :active => @localist_active_locale,
                         :symbol => Localist.symbol
        }

       render menu_template
      end
    end

    def localist_menu_html(supported_locales, active_locale, symbol)
      content_tag(:ul,
        supported_locales.map do |l|
          if active_locale == l
            content_tag(:li, localist_flag_tag(l, :class => 'localist_selected_flag'),
              :class => 'localist_selected'
            )
          else
            content_tag(:li,  
              link_to(
                content_tag(:span, localist_flag_tag(l,:class => 'localist_unselected_flag')),
                 url_for(params.merge({symbol=>l}))
              ),
              :class => 'localist_unselected'
            )
          end
        end.join("\n"),
        {:id => 'localist_menu', :class => 'localist_menu'}
      )
    end   
 
    def localist_flag_tag(locale, options={})
      country_code = Localist.country_code(locale)
      image_tag(File.join(Localist.flags_path,"#{country_code}.png"), options)
    end
        
  end # Helper

end 
