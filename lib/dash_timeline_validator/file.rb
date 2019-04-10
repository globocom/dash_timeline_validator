require "net/http"

module DashTimelineValidator
  class DashFile
    def self.fetch_file(origin, file_path = Options::ANALYZER_MANIFEST_PATH)
      dirname = File.dirname(file_path)
      unless File.directory? dirname
        FileUtils.mkdir_p(dirname)
      end

      if uri? origin
        download_and_save(origin, file_path)
      else
        FileUtils.cp origin, file_path
        File.read file_path
      end
    end

    def self.download_and_save(uri, path)
      content = Net::HTTP.get(URI.parse(uri))
      File.write(path, content)
      content
    end

    def self.uri?(string)
      uri = URI.parse(string)
      %w( http https ).include?(uri.scheme)
    rescue URI::BadURIError
      false
    rescue URI::InvalidURIError
      false
    end
  end
end
