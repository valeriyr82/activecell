# Base class for all views which display dynamicly
#
# Backbone.js still does not have convinient way for avoiding memory leaks
# This class added this functionality. Most of the code inspired by backbone.marionette
#
# Examples:
#
#   # Way to add subview in current view
#   # When router will remove this view all nested/sub view will be remove automatically
#   @createView SubView, collection: @something
#
#   # Convinient way to add event-listener
#   # on remove all events will be off and we don't get zombies
#   @addEvent @model, 'change', @dosomething
#
# For more information:
# https://gist.github.com/1288947
# http://stackoverflow.com/questions/7567404/backbone-js-repopulate-or-recreate-the-view/7607853#7607853
# https://github.com/marionettejs/backbone.marionette
module.exports = class BaseView extends Backbone.View

  constructor: (options = {}) ->
    super

    # Add view render callbacks
    # @see http://fahad19.tumblr.com/post/28158699664/afterrender-callback-in-backbone-js-views
    @render = _.wrap @render, (render, options) =>
      @beforeRender()
      render(options)
      @afterRender()
      @

  render: =>
    @$el.html @template?()
    @

  beforeRender: =>
    l("Rendering view", @)

  afterRender: =>

  createView: (klass, attrs) ->
    view = new klass(attrs)
    @views ||= []
    @views.push view
    view

  removeViews: ->
    view.remove() for view in @views

  addEvent: (object, event, callback, context = @) ->
    object.on(event, callback, context)
    @bindings ||= []
    @bindings.push object: object, event: event, callback: callback

  unbindFromAll: ->
    for binding in @bindings
      binding.object.off binding.event, binding.callback

  remove: ->
    # Dispose all childs
    @removeViews() if @views
    # This will unbind all events that this view has bound to
    @unbindFromAll() if @bindings
    # Uses the default Backbone.View.remove() method which removes this.el from the DOM and removes DOM events.
    super
