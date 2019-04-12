require "securerandom"

module DashTimelineValidator
  class Options
    ACCEPTABLE_DRIFT = (ENV["ACCEPTABLE_DRIFT"] || 2).to_i
    DEFAULT_PRESENTATION_DELAY = (ENV["DEFAULT_PRESENTATION_DELAY"] || 10).to_i
    BUFFERED_SEGMENTS = (ENV["BUFFERED_SEGMENTS"] || 2).to_i
    VERIFY_SEGMENTS_DURATION = ENV["VERIFY_SEGMENTS_DURATION"].eql? "true" || false
    ANALYZER_FOLDER = (ENV["ANALYZER_FOLDER"] || "data/#{SecureRandom.uuid}").freeze
    ANALYZER_MANIFEST_PATH = (ENV["ANALYZER_MANIFEST_PATH"] || "#{ANALYZER_FOLDER}/manifest.mpd").freeze
  end
end
