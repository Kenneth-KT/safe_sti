require 'active_record'
require 'active_support'
require 'safe_sti/invalid_definition_error'
require 'safe_sti/validation_error'

module SafeSti
  class Checker
    def self.for(klass)
      klass.instance_exec do
        @safe_sti_checker ||= ::SafeSti::Checker.new(klass)
      end
    end

    def initialize(klass)
      @klass = klass
      @preload_functions = []
      @preloaded = false
    end

    def sti_class?
      @klass < ::ActiveRecord::Base &&
        !@klass.abstract_class? &&
        @klass.columns_hash.include?(@klass.inheritance_column)
    end

    def add_preload_func(func)
      raise ArgumentError, "expect type of Proc" unless func.is_a?(Proc)
      @preload_functions << func
      @preloaded = false
    end

    def validate_and_preload_descendants
      return if @preloaded

      # Don't try to preload STI descendant classes while dependencies are being autoloaded,
      # it will create circular dependencies and prevent app from booting correctly.
      loading_dependencies = ::ActiveSupport::Dependencies.loading.present? rescue false
      return if loading_dependencies

      unless self.sti_class?
        @preloaded = true
        return
      end

      defined_children = self.defined_children
      defined_children.each do |child|
        raise ::SafeSti::InvalidDefinitionError, value: value unless child.is_a?(Class)
        warn_incorrect_definition child: child, parent: klass unless child.superclass == klass
      end

      superclass = klass.superclass
      superclass_checker = ::SafeSti::Checker.for(superclass)
      if superclass_checker.sti_class?
        superclass_children = superclass_checker.defined_children
        unless superclass_children.include?(klass)
          warn_missing_definition child: klass, parent: superclass
        end
      end
      @preloaded = true

      superclass_checker.validate_and_preload_descendants
      defined_children.each do |child|
        ::SafeSti::Checker.for(child).validate_and_preload_descendants
      end
    end

    def defined_children
      @preload_functions.collect(&:call).flatten
    end

    private

    attr_reader :klass

    def warn(message)
      ::SafeSti.warning_proc.call(message)
    end

    def warn_missing_definition(child:, parent:)
      warn(
        "Missing `safe_sti_child { #{child.name} }` inside class body of #{parent.name} class"
      )
    end

    def warn_incorrect_definition(child:, parent:)
      warn(
        "Remove `safe_sti_child { #{child.name} }` from class body of #{parent.name} class, " \
        "#{child.name} is not the direct superclass of #{parent.name}."
      )
    end
  end
end
