module.exports = class RevenueStream extends Backbone.Model
  paramRoot: 'revenue_stream'

  validate: (attrs) ->
    {name} = attrs
    if _.isEmpty(name)
      field: 'name', message: "Can't be blank"
    else if @collection.isUsed(name)
      field: 'name', message: 'Name has already been taken'
    else
      null
