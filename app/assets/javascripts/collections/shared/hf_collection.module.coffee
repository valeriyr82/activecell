# Base class for History/Forceast collections
module.exports = class HFCollection extends Backbone.Collection
  minify: ->
    @map (item) -> item.attributes

  getValue: ->
    attr = switch @constructor.name
      when 'ConversionSummary'  then (item) -> actual: item.customer_volume
      when 'ConversionForecast' then (item) -> plan:   item.conversion_forecast
      when 'FinancialSummary'   then (item) -> actual: item.amount_cents
