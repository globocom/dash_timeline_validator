require "iso8601"

module DashTimelineValidator
  class Report
    def self.report_info(value)
      value
    end

    def self.report_warn(value)
      "[WARN] #{value}"
    end

    def self.report_error(value)
      "[ERROR] #{value}"
    end

    def self.fill_report(report, mpd_leaf, key_name, default_value = nil, parser_fn = :identity)
      if mpd_leaf.respond_to? key_name
        report[key_name] = Report.report_info(self.send(parser_fn, mpd_leaf[key_name]))
      elsif default_value
        report[key_name] = Report.report_info(self.send(parser_fn, default_value))
      end
    end

    def self.fill_report_mandatory(report, mpd_leaf, key_name, parser_fn = :identity)
      if !mpd_leaf.respond_to? key_name
        report[key_name] = report_error("Mandatory #{key_name} is missing")
        error_exit(report)
      else
        report[key_name] = Report.report_info(self.send(parser_fn, mpd_leaf[key_name]))
      end
    end

    def self.duration_iso8601_to_i(start)
      ISO8601::Duration.new(start).to_seconds
    end

    def self.time_to_i(value)
      Time.parse(value).to_i
    end

    def self.identity(value)
      value
    end

    def self.to_i(value)
      value.to_i
    end
  end
end
