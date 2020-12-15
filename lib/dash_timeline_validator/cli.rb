require "fileutils"
require "securerandom"

module DashTimelineValidator
  ANALYZER_FOLDER = "data/#{SecureRandom.uuid}".freeze
  ANALYZER_MANIFEST_PATH = "#{ANALYZER_FOLDER}/manifest.mpd"

  DEFAULTS = {
    "acceptable_drift" => true,
    "presentation_delay" => 10,
    "buffered_segments" => 2,
    "verify_segments_duration" => false,
    "analyzer_folder" => ANALYZER_FOLDER,
    "analyzer_manifest_path" => ANALYZER_MANIFEST_PATH
  }

  def self.set_options(options)
    @@options = DEFAULTS.merge!(options)
  end

  def self.get_option(name)
    @@options[name]
  end

  class CLI
    def self.error_exit(report)
      DashTimelineValidator::Log.info(report)
      exit(-1)
    end

    def self.main(manifest, options = {})
      DashTimelineValidator.set_options(options)
      begin
        FileUtils.mkdir_p DashTimelineValidator.get_option("analyzer_folder")
        DashTimelineValidator::Log.info("The manifest #{manifest} will be processed at #{DashTimelineValidator.get_option("analyzer_folder")} folder.")

        mpd_content = DashTimelineValidator::DashFile.fetch_file(manifest)

        DashTimelineValidator::Log.info(DashTimelineValidator::Validator.analyze(manifest, mpd_content))
      rescue StandardError => e
        DashTimelineValidator::Log.error("There was an error: #{e.inspect}")
        DashTimelineValidator::Log.warn("Removing the folder #{DashTimelineValidator.get_option("analyzer_folder")}")
        FileUtils.rm_rf DashTimelineValidator.get_option("analyzer_folder")
      end
    end
  end
end
