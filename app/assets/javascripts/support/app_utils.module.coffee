module.exports =
  switchToCompany: (subdomain, redirectToMainPage = false) ->
    href = window.location.href
    newHref = href.replace("#{app.company.get('subdomain')}", "#{subdomain}")
    newHref = newHref.replace(/#.+$/, '') if redirectToMainPage
    window.location.href = newHref

  pullAlertsFromRails: ->
    alerts = $('#header').data('flash-messages')
    for alert in alerts
      type = alert[0]
      message = alert[1]
      @showAlert(type: type, message: message) if message isnt ''

  # Simple helper for displaying flash messages
  #   options.type (success, notice, error)
  #   options.heading the heading
  #   options.message the message
  showAlert: (options = {}) ->
    options.isFlash = true

    AlertMessageView = require('views/shared/alert_message')
    view = new AlertMessageView(options)
    $('#header #flash-messages').append(view.render().el)

  # TODO extract this to the separate class
  getGravatarFor: (email = '', options = {}) ->
    # fake email and corresponding avatar number
    fakeAvatars =
      'joan.harris@connected-bookkeepers.com' : 2
      'roger.sterling@sterlingcooper.com'     : 7
      'don.draper@sterlingcooper.com'         : 8
      'bert.cooper@sterlingcooper.com'        : 11
      'pete.campbell@sterlingcooper.com'      : 12

    isFakeEmail = _.contains(_.keys(fakeAvatars), email)
    if isFakeEmail
      @getFakeGravatar(fakeAvatars[email])
    else
      options.size ||= 40
      "http://www.gravatar.com/avatar/#{MD5(email)}?s=#{options.size}"

  getFakeGravatar: (number) ->
    "/assets/fake_avatars/avatar-#{number}.jpg"
