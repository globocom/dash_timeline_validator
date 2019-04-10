module DashTimelineValidator
  class Period
    def self.process(context, period, index)
      period_result = {}
      period_result["name"] = "Period-#{index}"
      DashTimelineValidator::Report.fill_report(period_result, period, "start", 0, :duration_iso8601_to_i)

      all_adaptation_sets = period.nodes.select { |n| n.name == "AdaptationSet" }

      period_result["adaptation_sets"] = all_adaptation_sets.each_with_index.map do |adaptation_set, i|
        DashTimelineValidator::AdaptationSet.process({root: context[:root], previous: period_result}, adaptation_set, i)
      end

      period_result
    end
  end
end
