StyleBaseView = require('./style_base_view')

module.exports = class Components extends StyleBaseView
  el: '#container'
  template: JST['admin/style_guide/components']

  initialize: ->
    $('li.style_guide_components').addClass('active')
