module DashTimelineValidator
  class Segment
    def self.process(context, ss)
      mpd_type = context[:root]["mpd"]["type"]
      previous = context[:previous]
      previous["S"] = []

      ss.each_with_index do |s, index|
        unless s.respond_to? "d"
          previous["S"].push(DashTimelineValidator::Report.report_error("Segment (#{index + 1}) doen't have mandatory value for 'd'"))
          error_exit(previous)
        end
        if mpd_type.eql? "dynamic" and !s.respond_to? "t"
          previous["S"].push(DashTimelineValidator::Report.report_warn("Segment <S d='#{s[:d]}' t='#{s[:t]}'/> doen't have a value for 't', it's necessary for MPD with 'dynamic' type"))
        end
      end

      timeline_segments = ss.map { |s| {d: s.d.to_i, t: s.respond_to?("t") ? s.t.to_i : 0, r: s.respond_to?("r") ? s.r.to_i : 0} }

      current_segment_number = context[:previous]["startNumber"].to_i

      timeline_segments.each_with_index do |current_segment, index|
        unless index.zero?
          previous_segment = timeline_segments[index - 1]
          current_segment_time = current_segment[:t]
          expected_segment_time = (previous_segment[:t] + (previous_segment[:d]) * (1 + previous_segment[:r]))
          drift = (expected_segment_time - current_segment_time).abs
          if drift > DashTimelineValidator::Options::ACCEPTABLE_DRIFT
            previous["S"].push(DashTimelineValidator::Report.report_warn("Timeline of <S d='#{current_segment[:d]}' t='#{current_segment[:t]}'/> was expected to be #{expected_segment_time}, but is #{current_segment_time} (drift = #{drift})"))
          end
        end

        if DashTimelineValidator::Options::VERIFY_SEGMENTS_DURATION
          (current_segment[:r].to_i + 1).times do |i|
            duration_report = check_segment_duration(context, current_segment, current_segment_number, i.zero?)
            previous["S"].push(duration_report) if duration_report
            current_segment_number += 1
          end
        end
      end
      previous.delete("S") if previous["S"].empty?
    end

    def self.check_segment_duration(context, current_segment, current_segment_number, download_init = true)
      init = context[:previous]["initialization"]
      media = context[:previous]["media"]
      base_path = context[:root]["base_path"]
      init_path = "#{DashTimelineValidator::Options::ANALYZER_FOLDER}/#{init}"

      DashTimelineValidator::DashFile.fetch_file("#{base_path}/#{init}", init_path) if download_init

      segment_file = media.gsub("$Number$", current_segment_number.to_s)
      segment_path = "#{DashTimelineValidator::Options::ANALYZER_FOLDER}/#{segment_file}"
      full_segment_path = "#{DashTimelineValidator::Options::ANALYZER_FOLDER}/#{segment_file}".gsub(".", "-complete.")
      DashTimelineValidator::DashFile.fetch_file("#{base_path}/#{segment_file}", segment_path)

      `cat #{init_path} #{segment_path} > #{full_segment_path}`
      duration = `mediainfo --Inform="General;%Duration%"  #{full_segment_path}`.to_i
      File.delete segment_path
      File.delete full_segment_path
      mediainfo_duration = duration.to_f / 1000 * context[:previous]["timescale"].to_i
      if (mediainfo_duration != current_segment[:d])
        return DashTimelineValidator::Report.report_warn("Mediainfo shows different duration for #{segment_file} compared to the advertised segment timeline item (#{(mediainfo_duration - current_segment[:d]).abs})")
      end
    end
  end
end
