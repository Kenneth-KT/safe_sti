require 'active_record'

module SafeSti
  module ActiverecordPatch
    def self.apply_patch(base_klass)
      unless base_klass.is_a?(Class) && base_klass < ::ActiveRecord::Base
        raise ArgumentError, "expect #{base_klass} to be subclass of ActiveRecord::Base"
      end

      base_klass.extend(ClassMethods)
    end

    module ClassMethods
      def safe_sti_child(&blk)
        safe_sti_checker.add_preload_func(blk)
      end

      def descendants(*)
        # this can make sure STI child classes is loaded before trying to make queries
        safe_sti_checker.validate_and_preload_descendants
        super
      end

      def new(*)
        # make sure the class cannot be properly used if check does not pass
        safe_sti_checker.validate_and_preload_descendants
        super
      end

      private

      def safe_sti_checker
        ::SafeSti::Checker.for(self)
      end
    end
  end
end
