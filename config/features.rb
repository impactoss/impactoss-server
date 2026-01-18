# config/features.rb
module Features
  def self.enabled?(feature)
    FEATURES.fetch(feature, false)
  end

  FEATURES = {
    measures: ENV.fetch('FEATURE_MEASURES', 'true') == 'true',
    indicators: ENV.fetch('FEATURE_INDICATORS', 'true') == 'true',
    progress_reports: ENV.fetch('FEATURE_REPORTS', 'true') == 'true',
  }.freeze
end
