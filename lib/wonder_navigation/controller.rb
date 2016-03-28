module WonderNavigation
  module Controller

    def self.included(controller)
      controller.before_action :set_default_wonder_navigation_page
    end

    def set_default_wonder_navigation_page
      page_action = case action_name.to_sym
                    when :create then :new
                    when :update then :edit
                    else action_name
                    end
      set_navigation_page "#{controller_path.tr('/','_')}_#{page_action}"
    end

    def set_wonder_navigation_object(navigation_object)
      @navigation_object = navigation_object
    end

    def set_navigation_page(navigation_page)
      @navigation_page = navigation_page.to_sym
    end

  end
end
