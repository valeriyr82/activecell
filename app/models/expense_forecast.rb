class ExpenseForecast
  include Api::BaseDocument
  include Api::BelongsCompany
  include Api::OccurrenceDocument
  include Api::ForecastDocument

  field :name,            type: String
  field :fixed_cost,      type: Integer
  field :percent_revenue, type: Float

  belongs_to :category
  belongs_to :occurrence_period, class_name: 'Period'

  OCCURRENCE_TYPES = ['Monthly', 'Annually', 'Fixed', 'Revenue Percent', 'Employee Count']
  validates_inclusion_of :occurrence, in: OCCURRENCE_TYPES, allow_blank: :true

  private

  # Business occurence conditions:
  #   if Monthly, fixed_cost
  #   if Annual, occurrence_month and fixed_cost
  #   if Fixed, occurence_period and fixed_cost
  #   if Revenue Percent, percent_revenue
  #   if Employee Count, fixed_cost
  def occurrence_fields(field = occurrence)
    [:id, :name, :category_id, :scenario_id, :occurrence] + case field
      when 'Monthly'         then [:fixed_cost]
      when 'Annually'        then [:fixed_cost, :occurrence_month]
      when 'Fixed'           then [:fixed_cost, :occurrence_period_id]
      when 'Revenue Percent' then [:percent_revenue]
      when 'Employee Count'  then [:fixed_cost]
      else []
    end
  end
end
