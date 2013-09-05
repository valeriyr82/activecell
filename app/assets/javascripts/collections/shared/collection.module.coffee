module.exports = class Collection extends Backbone.Collection
  ids: ->
    @pluck('id')

  eachIds: (callback) ->
    @map (item) => callback(item.id)

  prevId: (id) =>
    index = _.indexOf @ids(), id
    if index is 0 then undefined else @at(index - 1)?.id

  nextId: (id) =>
    index = _.indexOf @ids(), id
    if index is @length then undefined else @at(index + 1)?.id

  idsWithout: (ids) ->
    @chain().select((item) ->
      not _.include ids, item.id
    ).pluck('id').value()
