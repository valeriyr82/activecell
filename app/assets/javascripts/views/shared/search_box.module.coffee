BaseView = require('views/shared/base_view')

module.exports = class SearchBoxView extends BaseView
  template: JST['shared/search_box']

  events:
    'click .icon-eliminate'  : 'clearSearchString'
    'keyup .filter-list'     : 'filterView'

  clearSearchString: () ->
    @$('.filter-list').val('')
    @$('.icon-eliminate').hide()
    searchString = ''
    mediator.trigger('searchString:change', searchString)
    
  filterView: (event) ->
    if event.keyCode is 27
      @$('.filter-list').val('')
      event.stopPropagation()
    searchString = event.target.value
    if searchString.length
      @$('.icon-eliminate').show()
    else
      @$('.icon-eliminate').hide()
    mediator.trigger('searchString:change', searchString)

  render: (opts) ->
    @$el.html @template
      id              : opts.id or= ''
      additionalClass : opts.additionalClass or= ''
      placeholder     : opts.placeholder or= ''
      value           : opts.value or= ''
    @
