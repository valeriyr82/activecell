BaseView            = require('views/shared/base_view')
MetricSelectionView = require('views/shared/modal/metric_selection')

module.exports = class MainNavView extends BaseView

  events:
    'click #search-modal-link': 'showPopup'

  showPopup: ->
    @collection = []
    @model = []
    skips = 0
    modalView = @createView MetricSelectionView, collection: @collection, model: @model, callback: @func, skips: skips
    @$('.page-content-wrapper').append modalView.render(search: true, allowJumpTo: true).el
    modalView.show()

  func: ->
