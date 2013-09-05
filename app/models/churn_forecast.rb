class ChurnForecast
  include Api::BaseDocument
  include Api::BelongsCompany
  include Api::ForecastDocument

  field :churn_forecast, type: Integer

  belongs_to :period
  belongs_to :segment
end
