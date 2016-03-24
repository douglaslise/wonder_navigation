module WonderNavigation
  class ELabelNotDefined < StandardError; end
  class MenuItem
    attr_accessor :menu_instance, :level, :id, :parent_item, :subitems, :deferrables, :permission

    def xmethod_missing(method, *arguments)
      puts "missing #{method}(#{arguments})"
      if Rails.application.routes.url_helpers.respond_to?(method)
        Rails.application.routes.url_helpers.send(method, arguments)
      else

      end
    end

    def initialize(menu_instance, level, id, options = {}, &block)
      @level         = level
      @menu_instance = menu_instance
      @id            = id
      @subitems      = []
      @permission    = options[:permission]
      @menu_instance.items[id] = self
      initialize_deferrables(options)

      self.instance_eval(&block) if block_given?

      validate if options.fetch(:validate, true)
    end

    def validate
      unless label_deferrable.present?
        raise ELabelNotDefined.new("MenuItem #{id} was called without define a label text or proc")
      end
    end

    def menu(id, label = nil, options = {}, &block)
      if label.is_a?(Hash)
        options = label
      else
        options[:label] = label
      end
      sub_item = MenuItem.new(menu_instance, level + 1, id.to_sym, options, &block)
      sub_item.parent_item = self
      sub_item
    end

    def resource(id, options = {}, &block)
      new = show = nil
      index = menu "#{id}_index", options do
        new = menu "#{id}_new", "Novo", visible: false
        show = menu "#{id}_show" do
          label {|obj| obj.to_s }
          path {|obj| obj }
          menu "#{id}_edit", "Edição"
        end
      end
      index.instance_exec(index, new, show, &block) if block_given?
    end

    def breadcrumbs(object = nil)
      result = []
      if parent_item
        parent_object = object
        if parent_deferrable.present?
          parent_object = parent_deferrable.resolve(object)
        end
        result += parent_item.breadcrumbs(parent_object)
      end
      current = Crumb.new(id)
      current.label = label_deferrable.resolve(object)
      current.path  = path_deferrable.resolve(object) if path_deferrable.resolvable?(object)

      result << current
    end

    def entry_visible?(max_depth, usuario_atual)
      level < max_depth &&
        visible_deferrable.resolve(usuario_atual) &&
        label_deferrable.resolvable?(nil) &&
        has_permission?(usuario_atual)
    end

    def tree(current_page, max_depth, usuario_atual)
      MenuEntry.new(id, level).tap do |entry|
        entry.active  = id == current_page
        entry.visible = entry_visible?(max_depth, usuario_atual)
        if entry.visible
          entry.label   = label_deferrable.resolve(nil)
          entry.path    = path_deferrable.try_resolve(nil)
        end

        entry.children = subtree(current_page, max_depth, usuario_atual)
        entry.promote_active_state
      end
    end

    def has_permission?(usuario_atual)
      if permission
        Sis::PermissoesService.new(usuario_atual).possui_permissao?(permission)
      else
        true
      end
    end

    def parent_item=(parent_item)
      if parent_item
        @parent_item = parent_item
        parent_item.subitems << self
      elsif @parent_item
        @parent_item.subitems.delete(self)
        @parent_item = nil
      end
    end

    def label(&block)
      deferrables[:label] = DeferrableOption.new(block: block, name: "Label for #{id}")
    end

    def path(&block)
      deferrables[:path] = DeferrableOption.new(block: block, name: "Path for #{id}")
    end

    def visible(&block)
      deferrables[:visible] = DeferrableOption.new(block: block, name: "Visible for #{id}")
    end

    def parent(&block)
      deferrables[:parent] = DeferrableOption.new(block: block, name: "Parent for #{id}")
    end

    private

    def initialize_deferrables(options)
      @deferrables = {}
      visible = options.fetch(:visible, true)
      deferrables[:visible] = DeferrableOption.new(fixed: visible, name: "Visible for #{id}")
      deferrables[:label]   = DeferrableOption.new(fixed: options[:label], name: "Label for #{id}")
      deferrables[:path]    = DeferrableOption.new(fixed: options[:path], name: "Path for #{id}")
      deferrables[:parent]  = DeferrableOption.new(name: "Parent for #{id}")
    end

    def label_deferrable
      deferrables[:label]
    end

    def path_deferrable
      deferrables[:path]
    end

    def visible_deferrable
      deferrables[:visible]
    end

    def parent_deferrable
      deferrables[:parent]
    end

    def subtree(current_page, max_depth, usuario_atual)
      subitems.collect do |sub_item|
        sub_item.tree(current_page, max_depth, usuario_atual)
      end
    end
  end
end