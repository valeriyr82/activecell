AutosaveForm = require('views/settings/autosave_form')

module.exports = class UserForm extends AutosaveForm
  template:       JST['settings/user/form']
  avatarTemplate: JST['settings/user/form_avatar']

  initialize: ->
    @addEvent @model, 'change:email', @renderAvatar

  render: ->
    @$el.html @template(@model.toJSON())
    @renderAvatar()
    @

  renderAvatar: =>
    @$el.find('.avatar').html @avatarTemplate(avatarUrl: @model.getAvatarUrl(size: 120))
    @
