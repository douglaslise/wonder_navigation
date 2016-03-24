module WonderNavigation
  class DeferrableOption
    attr_accessor :fixed_value, :block, :name, :fixed_value_assigned

    def initialize(options = {})
      @fixed_value_assigned = options.has_key?(:fixed) && !options[:fixed].nil?
      @fixed_value = options[:fixed]
      @block       = options[:block]
      @name        = options[:name]
    end

    def present?
      fixed_value_assigned || block.present?
    end

    def resolvable?(object)
      fixed_value_assigned || block.present? && (object.present? || block.arity.zero?)
    end

    def try_resolve(object)
      resolve(object) if resolvable?(object)
    end

    def resolve(object)
      check_resolvable(object)
      fixed_value_assigned ? fixed_value : block.call(object)
    end

    private

    def check_resolvable(object)
      unless resolvable?(object)
        # raise EObjectNotSupplied.new "Parent block defined for menu #{id} requiring an object, but none (or nil) was supplied on getting breadcrumbs"
        if present?
          raise EObjectNotSupplied.new "A block was defined to require an object but none (or nil) was supplied on deferrable option #{name}"
        else
          raise EDeferrableOptionEmpty.new "Neither a fixed value or a block was passed to deferrable option #{name}"
        end
      end
    end
  end
  class EObjectNotSupplied < StandardError; end
  class EDeferrableOptionEmpty < StandardError; end
end
