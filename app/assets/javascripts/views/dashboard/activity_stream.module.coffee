BaseView = require('views/shared/base_view')
Activities = require('collections/activities')
ActivityStreamMessageView = require('views/dashboard/activity_stream/message')

module.exports = class ActivityStreamView extends BaseView
  template: JST['dashboard/activity_stream']
  
  events:
    'submit #activity-stream-form': 'createMessage'

  initialize: ->
    @perPage = 24
    @isLoading = false
    @collection = new Activities()
    @collection.fetch()

    @addEvent @collection, 'reset', @render
    @addEvent @collection, 'add', @render
    @addEvent @collection, 'remove', @render

  render: =>
    @page = 1
    @$el.html @template()
    @appendMessages(@page)
    
    # unfortunately this event doesn't work when added to the events hash
    # probably because it doesn't work with .on
    @$('.content-block').scroll(@checkScroll)
    @

  addOne: (activity) =>
    messageView = @createView ActivityStreamMessageView, model: activity, collection: @collection
    @$el.find('ul.articles-list').append messageView.render().el

  appendMessages: () ->
    @isLoading = true
    paginated = @collection.paginate(@page, @perPage)
    _.each paginated, @addOne
    @isLoading = false

  checkScroll: =>
    triggerPoint = 30 # 30px from the bottom
    el = @$el.find('.content-block')[0]
    if not @isLoading and el.scrollTop + el.clientHeight + triggerPoint > el.scrollHeight
      @page += 1
      @appendMessages()
    
  createMessage: (event) ->
    event?.preventDefault()

    $input = @$('#activity-stream-input')
    messageContent = $input.val()
    spinner = new Spinner(radius: 2, width: 2, length: 4, speed: 1.4, color: '#eee').spin()
    $input.after(spinner.el)
    return if messageContent is ''

    @collection.create { content: messageContent },
      wait: true
      success: =>
        $input.val('')
        @collection.fetch()
