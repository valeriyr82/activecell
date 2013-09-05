class Scenario
  include Api::NameDocument
  include Api::BelongsCompany
  include Api::ValidateLast

  DEFAULT_NAME = 'Base Plan'

  has_many :churn_forecast,      class_name: 'ChurnForecast'
  has_many :conversion_forecast, class_name: 'ConversionForecast'
  has_many :unit_cac_forecast,   class_name: 'UnitCacForecast'
  has_many :unit_rev_forecast,   class_name: 'UnitRevForecast'
  has_many :expense_forecasts
  has_many :staffing_forecasts
end
