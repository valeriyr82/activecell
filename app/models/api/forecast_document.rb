module Api::ForecastDocument
  extend ActiveSupport::Concern

  included do
    belongs_to :scenario
  end
end
