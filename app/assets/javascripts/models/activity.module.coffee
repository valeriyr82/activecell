module.exports = class Activity extends Backbone.Model
  paramRoot: 'activity'
  urlRoot: 'api/v1/activities'

  getContent: ->
    @get('content')

  getSenderName: ->
    @get('sender').name

  getSenderEmail: ->
    @get('sender').email

  getSenderAvatarUrl: ->
    app.utils.getGravatarFor(@getSenderEmail(), size: 36)

  getDate: ->
    @get('created_at_in_words')
