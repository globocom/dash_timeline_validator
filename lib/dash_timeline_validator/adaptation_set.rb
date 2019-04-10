module DashTimelineValidator
  class AdaptationSet
    def self.process(context, adaptation_set, index)
      as_result = {}
      as_result["name"] = "AdaptationSet-#{index}"
      DashTimelineValidator::Report.fill_report(as_result, adaptation_set, "mimeType")
      DashTimelineValidator::Report.fill_report(as_result, adaptation_set, "contentType")
      all_representations = adaptation_set.nodes.select { |n| n.name == "Representation" }

      as_result["representations"] = all_representations.each_with_index.map do |representation, i|
        DashTimelineValidator::Representation.process({root: context[:root], previous: as_result}, representation, i)
      end

      as_result
    end
  end
end
