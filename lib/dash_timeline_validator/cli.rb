require "fileutils"

module DashTimelineValidator
  DEFAUTLS = {
    :acceptable_drift => true,
    :presentation_delay => 10,
    :buffered_segments => 2,
    :verify_segments_duration => false
  }

  def self.set_options(options)
    @@options = DEFAUTLS.merge!(options)
  end

  def self.get_options
    @@options
  end

  class CLI
    def self.error_exit(report)
      DashTimelineValidator::Log.info(report)
      exit(-1)
    end

    def self.main(manifest, options = {})
      DashTimelineValidator.set_options(options)
      begin
        FileUtils.mkdir_p DashTimelineValidator::Options::ANALYZER_FOLDER
        DashTimelineValidator::Log.info("The manifest #{manifest} will be processed at #{DashTimelineValidator::Options::ANALYZER_FOLDER} folder.")

        mpd_content = DashTimelineValidator::DashFile.fetch_file(manifest)

        DashTimelineValidator::Log.info(DashTimelineValidator::Validator.analyze(manifest, mpd_content))
      rescue StandardError => e
        DashTimelineValidator::Log.error("There was an error: #{e.inspect}")
        DashTimelineValidator::Log.warn("Removing the folder #{DashTimelineValidator::Options::ANALYZER_FOLDER}")
        FileUtils.rm_rf DashTimelineValidator::Options::ANALYZER_FOLDER
      end
    end
  end
end
