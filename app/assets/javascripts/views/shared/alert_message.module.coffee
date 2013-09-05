BaseView = require('views/shared/base_view')

module.exports = class AlertMessageView extends BaseView
  template: JST['shared/alert_message']
  
  events:
    'click .close' : 'closeAlert'
    
  render: ->
    @$el.append @template
      type    : @options.type
      heading : @options.heading
      message : @options.message

    if @options.isFlash
      setTimeout(@closeAlert, 3000)

    @

  closeAlert: =>
    @$el.fadeOut 700, =>
      @$el.remove()
