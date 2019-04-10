require "fileutils"

module DashTimelineValidator
  class CLI
    def self.error_exit(report)
      DashTimelineValidator::Log.info(report)
      exit(-1)
    end

    def self.main(manifest)
      begin
        FileUtils.mkdir_p DashTimelineValidator::Options::ANALYZER_FOLDER
        DashTimelineValidator::Log.info("The manifest #{manifest} will be processed at #{DashTimelineValidator::Options::ANALYZER_FOLDER} folder.")

        mpd_content = DashTimelineValidator::DashFile.fetch_file(manifest)

        DashTimelineValidator::Log.info(DashTimelineValidator::Validator.analyze(manifest, mpd_content))
      rescue StandardError => e
        DashTimelineValidator::Log.warn("There was an error: #{e.inspect}")
        DashTimelineValidator::Log.warn(e.backtrace.join("\n\t"))
        DashTimelineValidator::Log.warn("Removing the folder #{DashTimelineValidator::Options::ANALYZER_FOLDER}")
        FileUtils.rm_rf DashTimelineValidator::Options::ANALYZER_FOLDER
      end
    end
  end
end
