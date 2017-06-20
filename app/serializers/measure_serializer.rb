class MeasureSerializer < ApplicationSerializer
  attributes :title, :description, :target_date, :draft, :outcome, :indicator_summary, :target_date_comment
end
