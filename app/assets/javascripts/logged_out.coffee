#= require sprockets/commonjs
#= require jquery
#= require jquery_ujs
#= require underscore
#= require backbone
#
#  Logged out files
#= require lib/subdomain_generator.module
#= require_tree ./logged_out/views

#= require support/app_utils.module
#= require support/utils
#= require views/shared/base_view.module
#= require views/shared/alert_message.module
#= require views/shared/fancy_checkboxes
#= require ../templates/shared/alert_message

SignUpView = require('logged_out/views/sign_up')

$ ->
  new SignUpView()

  Utils = require('support/app_utils')
  Utils.pullAlertsFromRails()
