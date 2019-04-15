module DashTimelineValidator
  class Representation
    def self.process(context, representation, index)
      representation_result = {}
      representation_result["name"] = "Representation-#{index}"

      DashTimelineValidator::Report.fill_report(representation_result, representation, "bandwidth")
      DashTimelineValidator::Report.fill_report(representation_result, representation, "codecs")
      DashTimelineValidator::Report.fill_report(representation_result, representation, "presentationTimeOffset", 0, :duration_iso8601_to_i)

      if representation.respond_to? "SegmentTemplate"
        segment_template = representation.SegmentTemplate
        representation_result["SegmentTemplate"] = {}

        DashTimelineValidator::Report.fill_report_mandatory(representation_result["SegmentTemplate"], segment_template, "timescale", :to_i)
        DashTimelineValidator::Report.fill_report_mandatory(representation_result["SegmentTemplate"], segment_template, "media")
        DashTimelineValidator::Report.fill_report(representation_result["SegmentTemplate"], segment_template, "initialization")
        DashTimelineValidator::Report.fill_report_mandatory(representation_result["SegmentTemplate"], segment_template, "startNumber")

        if context[:root]["mpd"]["type"].eql? "dynamic"
          report_edge_timeline_information = report_edge_timeline_information(context, representation_result, segment_template.SegmentTimeline.nodes)
          representation_result["SegmentTemplate"]["timeline"] = report_edge_timeline_information
        end

        if segment_template.respond_to? "SegmentTimeline"
          DashTimelineValidator::Segment.process({root: context[:root], previous: representation_result["SegmentTemplate"]}, segment_template.SegmentTimeline.nodes)
        end
      end

      representation_result
    end

    def self.report_edge_timeline_information(context, representation_result, ss)
      client_wallclock = context[:root]["client_wallclock"]
      ast = context[:root]["mpd"]["availabilityStartTime"]
      timescale = representation_result["SegmentTemplate"]["timescale"]
      max_duration = ss.map { |s| s[:d].to_i }.max / timescale
      min_buffer_time = context[:root]["mpd"]["minBufferTime"]
      suggested_resentation_delay = context[:root]["mpd"]["suggestedPresentationDelay"]
      default_presentation_delay = [DashTimelineValidator.get_options[:presentation_delay], (min_buffer_time * 1.5)].max
      timeline_delay = suggested_resentation_delay.nil? ? default_presentation_delay : suggested_resentation_delay

      # suggested streaming edge based on shaka's behavior
      streaming_edge = client_wallclock - ast - DashTimelineValidator::Options::BUFFERED_SEGMENTS * max_duration - timeline_delay

      last_segment = ss.last
      last_available_time = (last_segment[:t].to_i + (last_segment[:d].to_i * last_segment[:r].to_i)) / timescale

      if streaming_edge > last_available_time
        report = DashTimelineValidator::Report.report_warn("Live edge is at #{streaming_edge}s but last segment in timeline starts at #{last_available_time}s")
      else
        report = DashTimelineValidator::Report.report_info("Live edge is at #{streaming_edge}s and last segment in timeline starts at #{last_available_time}s")
      end

      report
    end
  end
end
