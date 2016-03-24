module WonderNavigation
  module Helper

    def navigation_breadcrumb
      crumbs = crumbs_for_current_page
      crumbs.any? ? breadcrumb(crumbs) : "Breadcrumb não definido"
    end

    def navigation_title_breadcrumb(prefix)
      crumbs = crumbs_for_current_page.collect(&:label)
      crumbs[0] = prefix
      crumbs.join(" - ")
    end

    def menu_tree
      WonderNavigation::MenuManager.get(:menu_probus).menu_tree(current_page: @navigation_page, usuario_atual: usuario_atual)
    end

    private

    def crumbs_for_current_page
      page = @navigation_page

      object = @navigation_object
      unless object
        # Se o objeto não for fornecido via set_wonder_navigation_object então tenta obter uma variável de instância com o nome do controller no singular
        mod, resource = controller_path.split("/")
        mod, resource = nil, mod if resource.nil?
        variable_name = [mod, resource.singularize].compact.join("_")
        variable_name = "@#{variable_name}"
        object = controller.instance_variable_get(variable_name.to_sym)
      end
      # object ||= @navigation_parent_object
      crumbs_for(page.to_sym, object)
    end

    def crumbs_for(id, object)
      menu = WonderNavigation::MenuManager.get(:menu_probus)
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
