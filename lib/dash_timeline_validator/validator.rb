require "ox"

module DashTimelineValidator
  class Validator
    def self.analyze(manifest, mpd_content)
      report = {}
      mpd = nil

      if DashTimelineValidator::DashFile.uri? manifest
        uri = URI(manifest)
        report["base_path"] = DashTimelineValidator::Report.report_info("#{uri.scheme}://#{uri.host}#{uri.path.split("/").reverse.drop(1).reverse.join("/")}")
      else
        report["base_path"] = DashTimelineValidator::Report.report_info(DashTimelineValidator.get_option("analyzer_folder"))
      end

      begin
        mpd = Ox.load(mpd_content)
      rescue
        DashTimelineValidator::Log.error("Error while parsing #{manifest} it might be malformed (a non 2xx response)")
        error_exit(report)
      end

      report["client_wallclock"] = DashTimelineValidator::Report.report_info(client_wallclock(mpd))

      report["mpd"] = {}

      DashTimelineValidator::Report.fill_report(report["mpd"], mpd.MPD, "type", "static")
      DashTimelineValidator::Report.fill_report_mandatory(report["mpd"], mpd.MPD, "minBufferTime", :duration_iso8601_to_i)

      if report["mpd"]["type"] == "dynamic"
        DashTimelineValidator::Report.fill_report_mandatory(report["mpd"], mpd.MPD, "availabilityStartTime", :time_to_i)
        if mpd.MPD.respond_to? "suggestedPresentationDelay"
          DashTimelineValidator::Report.fill_report(report["mpd"], mpd.MPD, "suggestedPresentationDelay", 0, :duration_iso8601_to_i)
        end
      else
        DashTimelineValidator::Report.fill_report(report["mpd"], mpd.MPD, "availabilityStartTime", Time.now.iso8601(0), :time_to_i)
      end

      all_periods = mpd.MPD.nodes.select { |n| n.name == "Period" }
      report["mpd"]["periods"] = all_periods.each_with_index.map do |period, index|
        DashTimelineValidator::Period.process({root: report, previous: report["mpd"]}, period, index)
      end

      report
    end

    def self.client_wallclock(mpd)
      if mpd.MPD.respond_to? "UTCTiming"
        if mpd.MPD.UTCTiming["schemeIdUri"].eql? "urn:mpeg:dash:utc:direct:2014"
          raw_time = mpd.MPD.UTCTiming["value"]
        elsif mpd.MPD.UTCTiming["schemeIdUri"].eql? "urn:mpeg:dash:utc:http-iso:2014"
          raw_time = Net::HTTP.get(URI.parse(mpd.MPD.UTCTiming["value"]))
        end
      end

      if raw_time.nil?
        return DateTime.now.to_time.to_i
      end

      DateTime.parse(raw_time).to_time.to_i
    end
  end
end
