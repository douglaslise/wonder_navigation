module WonderNavigation
  module Helper

    def navigation_breadcrumb
      crumbs = crumbs_for_current_page
      crumbs.any? ? breadcrumb(crumbs) : "Breadcrumb undefined for '#{@navigation_page}'"
    end

    def navigation_title_breadcrumb(prefix)
      crumbs = crumbs_for_current_page.collect(&:label)
      crumbs[0] = prefix
      crumbs.join(" - ")
    end

    def menu_tree(menu_id, current_user)
      WonderNavigation::MenuManager.get(menu_id).menu_tree(current_page: @navigation_page, current_user: current_user)
    end

    private

    def crumbs_for_current_page(menu_id = :default)
      page = @navigation_page

      object = @navigation_object
      unless object
        # If object was not given by set_wonder_navigation_object then try get an instance variable called with the same name that the controller in singular
        mod, resource = controller_path.split("/")
        mod, resource = nil, mod if resource.nil?
        variable_name = [mod, resource.singularize].compact.join("_")
        variable_name = "@#{variable_name}"
        object = controller.instance_variable_get(variable_name.to_sym)
      end
      # object ||= @navigation_parent_object
      crumbs_for(menu_id, page.to_sym, object)
    end

    def crumbs_for(menu_id, id, object)
      menu = WonderNavigation::MenuManager.get(menu_id)
      if menu.item_exists?(id)
        menu.breadcrumb_for(id, object)
      else
        []
      end
    end

    def breadcrumb(crumbs)
      content_tag(:ol, class: "breadcrumb") do
        raw(crumbs.collect do |menu_item|
          content_tag(:li) do
            if menu_item.path
              link_to menu_item.label, menu_item.path
            else
              menu_item.label
            end
          end
        end.join(" "))
      end
    end


  end
end
