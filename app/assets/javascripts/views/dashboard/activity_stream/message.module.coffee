BaseView = require('views/shared/base_view')

module.exports = class ActivityStreamView extends BaseView
  template: JST['dashboard/activity_stream/message']

  render: ->
    @$el.html @template(@_tempateContext())
    @

  _tempateContext: ->
    senderAvatarUrl: @model.getSenderAvatarUrl()
    senderName: @model.getSenderName()
    content: @model.getContent()
    date: @model.getDate()
