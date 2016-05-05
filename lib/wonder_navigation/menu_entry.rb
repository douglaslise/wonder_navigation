module WonderNavigation
  class MenuEntry
    attr_accessor :id, :label, :path, :level, :active, :visible, :children, :icon
    def initialize(id, level)
      @id = id
      @level = level
      @children = []
    end

    def active?
      active || children.any?(&:active?)
    end

    def has_visible_children?
      children.any?(&:visible)
    end

    def has_active_children?
      children.any?(&:active)
    end

    def promote_active_state
      self.active ||= has_active_children?
    end

    def visible_children
      children.select(&:visible)
    end

    def self.level_class(level)
      classes = {
        2 => "second",
        3 => "third"
      }
      classes[level]
    end
  end
end
