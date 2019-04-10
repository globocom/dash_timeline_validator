require "awesome_print"

module DashTimelineValidator
  class Log
    def self.info(msg)
      ap msg
    end

    def self.warn(msg)
      ap msg
    end

    def self.error(msg)
      ap msg
    end
  end
end
