StyleBaseView = require('./style_base_view')

module.exports = class Scaffolding extends StyleBaseView
  el: '#container'
  template: JST['admin/style_guide/scaffolding']

  initialize: ->
    $('li.style_guide_scaffolding').addClass('active')