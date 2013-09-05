class StaffingForecast
  include Api::BaseDocument
  include Api::BelongsCompany
  include Api::OccurrenceDocument
  include Api::ForecastDocument

  field :fixed_delta,       type: Integer
  field :revenue_threshold, type: Integer

  belongs_to :employee_type
  belongs_to :occurrence_period, class_name: 'Period'

  OCCURRENCE_TYPES = ['Monthly', 'Annually', 'Fixed', 'Revenue Threshold']
  validates_inclusion_of :occurrence, in: OCCURRENCE_TYPES, allow_blank: :true

  private

  # Business occurence conditions:
  #   if Monthly, fixed_cost
  #   if Annual, occurrence_month and fixed_delta
  #   if Fixed, occurence_period and fixed_delta
  #   if Revenue Threshold, revenue_threshold
  def occurrence_fields(field = occurrence)
    [:id, :scenario_id, :employee_type_id, :occurrence] + case field
      when 'Monthly'           then [:fixed_delta]
      when 'Annually'          then [:fixed_delta, :occurrence_month]
      when 'Fixed'             then [:fixed_delta, :occurrence_period_id]
      when 'Revenue Threshold' then [:revenue_threshold]
      else []
    end
  end
end
