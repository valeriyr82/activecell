BaseView = require('views/shared/base_view')

module.exports = class MainNavView extends BaseView
  el: '#main_nav'

  changeActive: (@activeNav) ->
    $newNav  = @$("li[data-nav=#{@activeNav}]")
    newIndex = @$('li').index($newNav) - 1

    @$('li.active').removeClass('active')
    @$('#nav_ribbon').animate({top: 64*newIndex}, 200)
    $newNav.addClass('active')
