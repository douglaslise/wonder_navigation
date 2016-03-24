module WonderNavigation
  class ENotDefinedMenu < StandardError; end
  class Menu
    attr_reader :items

    # def initialize(menu_id, menu_manager = MenuManager, &block)
    #   @items = {}
    #   menu_maanager.set(menu_id, self)
    #   items[:root] = MenuItem.new(self, 0, :root, &block)
    #   # items[:root].instance_eval(&block)
    # end

    def initialize
      @items = {}
    end

    def self.register(menu_id, menu_manager = MenuManager, &block)
      instance = menu_manager.fetch(menu_id)
      unless instance
        instance = Menu.new
        instance.items[:root] = MenuItem.new(instance, 0, :root, validate: false)
        menu_manager.set(menu_id, instance)
      end

      instance.items[:root].instance_eval(&block)

      instance
    end

    def item_exists?(id)
      items[id].present?
    end

    def breadcrumb_for(id, object = nil)
      if items[id]
        items[id].breadcrumbs(object)
      else
        raise ENotDefinedMenu.new "Menu '#{id}' not defined"
      end
    end

    def menu_tree(options = {})
      usuario_atual = options[:usuario_atual]
      current_page  = options[:current_page]
      max_depth     = options[:max_depth] || 10
      items[:root].tree(current_page, max_depth, usuario_atual)
    end

    def menu_tree_flat(options = {})
      extract_children menu_tree(options)
    end

    private

    def extract_children(menu_entry)
      result = []
      result << menu_entry
      result << menu_entry.visible_children.collect do |child|
        extract_children(child)
      end
      menu_entry.children = []

      result.flatten
    end
  end
end
