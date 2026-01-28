module FeatureSpecHelpers
  def flash?(content)
    page.has_css?(".callout", text: content)
  end
end
