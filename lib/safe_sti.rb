require 'safe_sti/activerecord_patch'
require 'safe_sti/checker'

module SafeSti
  class << self
    attr_accessor :warning_proc

    def warn_with_raise!
      self.warning_proc = proc do |message|
        raise ValidationError, message
      end
    end

    def warn_with_stderr!
      self.warning_proc = proc do |message|
        $stderr.puts "[SafeSTI warning] #{message}"
      end
    end

    def warn_with_rails_logger_warn!
      self.warning_proc = proc do |message|
        ::Rails.logger.warn "[SafeSTI warning] #{message}"
      end
    end

    def enable_for(klass)
      ::SafeSti::ActiverecordPatch.apply_patch(klass)
    end
  end

  warn_with_stderr! if self.warning_proc.nil?
end
