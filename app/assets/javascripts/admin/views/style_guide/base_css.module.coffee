#= require ./style_base_view.module
StyleBaseView = require('./style_base_view')

module.exports = class BaseCSS extends StyleBaseView
  el: '#container'
  template: JST['admin/style_guide/base_css']

  initialize: ->
    $('li.style_guide_base_css').addClass('active')