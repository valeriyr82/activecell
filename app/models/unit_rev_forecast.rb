class UnitRevForecast
  include Api::BaseDocument
  include Api::BelongsCompany
  include Api::ForecastDocument

  field :unit_rev_forecast, type: Integer

  belongs_to :revenue_stream
  belongs_to :segment
end
