# Wrapper for multidimensional arrays. It uses principle that
# in javascript arrays are objects(with specific keys) and for perfomance
# no matter how we store the data as array or object.
#
# name       - Name of collection (required)
# schema     - Sets order and type nested attributes (required)
#              data save based on this attribute
# multiplier - For percentage data equal 100, by default 1
#
# Examples
#
#   class ConversionRates extends BaseCollection
#     name: 'conversionRates'
#     schema: ['notFirstStageId', 'channelId', 'monthId']
#     multiplier: 100
#
#   conversionRates = new ConversionRates()
#   conversionRates.collections
#   # => [Array[stages.lenght], Array[channels.lenght], Array[months.length]]
#
#   conversionRates.values
#   # => object with data
#   2: # stage id
#     1: # channel id, contains values for every month
#       1:  70 # first month id with value
#       2:  17 # second month id with value
#       #   ...
#       36: 27 # last month id with value
#     2:
#       1:  46
#       2:  66
#       #   ...
#       36: 14
#     # other channels with data for stage with id = 2
#   3: # another stage id
#     1: # channels for another stage
#       1:  16
#       #   ...
#       36: 34
#     # other channels with data for stage with id = 3
#
#   # Get value for notFirstStageId = 2 and channelId = 1 and monthId = 36
#   conversionRates.get(2, 1, 36)
#   # => 27
#
#   # Set 75% for notFirstStageId = 3, channelId = 1 and monthId = 1
#   conversionRates.set(75, 3, 1, 1)
#
#   conversionRates.isMonth()
#   # => true
module.exports = class BaseCollection
  # Include methods from Backbone.Events for binding support
  _.extend(@::, Backbone.Events)

  multiplier: 1

  constructor: ->
    @inputs      = admin.inputs[@name] || []
    @collections = (admin.schemaMap(field) for field in @schema)
    @values      = @initValues()

  # Recursive function which uses @inputs and @collections for builds @values
  # Attributes used for recursive callbacks
  #
  # Returns object with structured data
  initValues: (values = {}, inputs = @inputs, level = 0) ->
    for item, order in @collections[level]
      value = inputs[order] ? 0
      if level is @schema.length - 1
        values[item.id] = value
      else
        values[item.id] = {}
        @initValues(values[item.id], value, level + 1)
    values

  # Get value by params
  #
  # args - Arguments split a comma and bases on schema.
  #        If schema is ['channelId', 'monthId']
  #        then get(1,2) will be equal channelId=1 and monthId=2
  #
  # Examples
  #
  #   conversionRates.get(2, 1, 1)
  #   # => 70
  #
  #   conversionRates.get(2, 1)
  #   # => {1: 70, 2: 17, ..., 36: 27}
  #
  # Returns value or object with group of values
  get: (args...) ->
    result = @values
    result = result[key] for key in args
    result = result / @multiplier if _.isNumber(result)
    result

  # Changes value and fire trigger `change`
  #
  # value - New value
  # args  - Arguments split a comma and bases on schema
  #         for navigation to specifically value.
  #
  # Examples
  #
  #   conversionRates.set(45, 2, 1, 1)
  #   conversionRates.get(2, 1, 1)
  #   # => 45
  #
  # Returns nothing.
  set: (value, args...) ->
    result = @values
    result = result[key] for key in args.slice(0, -1)
    result[_.last(args)] = value
    @trigger('change', args, value, @)

  # Combine information for display
  #
  # Returns array of nested arrays
  print: (result = [], args = [], level = 0) ->
    for item in @collections[level]
      args[level] = item.id
      if level >= @schema.length - 2 and @isMonth()
        result.push args.concat _.values(@get(args...))
      else if level >= @schema.length - 1 and !@isMonth()
        result.push args.concat @get(args...) * @multiplier
      else
        @print(result, args, level + 1)
    result

  # Check that collection has monthId attribute
  #
  # Returns true or false
  isMonth: ->
    _.last(@schema) is 'monthId'
