#= require sprockets/commonjs
#= require jquery
#= require jquery_ujs
#= require underscore
#= require backbone
#= require backbone_rails_sync
#
#  PLUGINS
#= require moment
#= require recurly
#= require jquery.ui.dialog
#= require jquery.ui.slider
#= require jquery.ui.button
#= require jquery.event.drag-2.0
#= require jquery.event.drop-2.0
#= require jquery-fileupload/basic
#= require jquery.spin
#= require bootstrap-colorpicker
#= require bootstrap-modal
#= require bootstrap-tooltip
#= require bootbox
#= require backbone.validations
#= require webtoolkit.md5
#= require slick.rowselectionmodel
#= require slick.rowmovemanager
#= require slick.core
#= require slick.dataview
#= require slick.editors
#= require slick.formatters
#= require slick.grid
#= require slick.groupitemmetadataprovider
#= require slick.remotemodel
#= require d3.v2
#= require d3-bootstrap-plugins
#= require jquery.mousewheel
#= require mwheelIntent
#= require jquery.jscrollpane.js
#
#  APPLICATION
#= require_tree ../templates
#= require_tree ./support
#= require_tree ./lib
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./analysis
#= require_tree ./views/shared
#= require_tree ./views
#= require_tree ./routers
#= require_self

Router = require('routers/router')

$ ->
  # Setup tooltip for the main nav
  $("#main_nav li").tooltip
    placement: 'right'
    delay: { show: 0, hide: 0 }

  window.mediator = require('lib/mediator')
  window.mediator.on "route:rendered", $.setupLabel

  window.app = new Router()
  app.createApplication()

  app.utils.pullAlertsFromRails()

  # Handler for ajax errors
  $(document).ajaxError (e, xhr, options) ->
    payment_required = 402

    switch xhr.status
      # Force redirect to the account setting page
      when payment_required then app.settingsAccount()
