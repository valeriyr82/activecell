module.exports = class Countries extends Backbone.Collection
  url: 'api/v1/countries'

  comparator: (country) ->
    country.get('name')