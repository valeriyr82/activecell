BaseCollection = require('./base_collection')

# Adds specific forecast functionality to BaseCollection
#
# name        - Forecast name (required)
# schema      - Schema for attributes (required)
# triggers    - Object with functions which called when object was changed
#               use short versions of variables from admin
#
# Examples
#
#   class ConversionForecast extends ForecastCollection
#     name: 'conversionForecast'
#     schema: ['stageId', 'channelId', 'segmentId', 'monthId']
#     triggers:
#       toplineGrowth: (args) -> l("toplineGrowth changed with #{args.channelId} and #{args.monthId}")
#
#   conversionForecast = new ConversionForecast()
#
#   # Build forecast based on current inputs
#   conversionForecast.build()
#
#   # Turns on all triggers
#   conversionForecast.onTriggers()
#   admin.toplineGrowth.set(5, 1, 1)
#   # => 'toplineGrowth changed'
module.exports = class ForecastCollection extends BaseCollection
  # Raw method for calculating a forecast value. Extend this.
  #
  # args - One or more attributes from @schema
  #
  # Returns not rounded value.
  calculate: (args...) ->

  # Builds values for every element
  build: (level = 0, args = []) ->
    for item in @collections[level]
      args[level] = item.id
      if level >= @schema.length - 1
        @set(args...)
      else
        @build(level + 1, args)

  # Turns On triggers based on @triggers. Name `this` uses for self triggers
  onTriggers: ->
    for collectionName, callback of @triggers
      collection = if collectionName is 'this' then @ else admin[collectionName]
      collection.on('change', @wrapCallback(callback), @)

  # Calculates new value based on params and saves to @values
  #
  # Returns nothing.
  set: (args...) ->
    value = @calculate(args...)
    super Math.round(value), args...

  # Private: pass args as object with params to trigger function
  #
  # Returns trigger function
  wrapCallback: (defaultCallback) ->
    (args, value, collection) ->
      attributes = {}
      attributes[key] = args[order] for key, order in collection.schema
      defaultCallback.call(@, attributes)
