BaseView = require('views/shared/base_view')

module.exports = class UserCompany extends BaseView
  template: JST['settings/user/company']
  tagName: 'tr'

  events:
    'click a.btn.remove-company': 'removeCompany'
    'click a.btn.log-on': 'changeCompany'

  initialize: ->
    @user = app.user
    @currentCompany = app.company
    @currentCompany.set("user_ids_count", @collection.length);

  render: ->
    @$el.addClass("company-#{@model.id}")
    @$el.html @template(company: @model.toJSON(), isCurrentCompany: @isCurrentCompany())
    @

  # actually, this doesn't remove this company but disconnects current user from it
  removeCompany: (event) ->
    event?.preventDefault()

    # TODO: we need to have an info how many users remain for this company
    #       probably we'll need to have such field when fetching the companies collection
    #
    #if @currentCompany.hasOnlyOneUser()
    #  return unless confirm(
    #    """You are the last user in #{@currentCompany.get('name')}.
    #    Removing yourself will close your account and delete this company. This cannot be undone.
    #    """
    #  )
    #else
    bootbox.confirm 'Are you sure?', (confirmed) =>
      return unless confirmed

      @model.removeUser @user,
        success: =>
          if @isCurrentCompany()
            # reload the page and sign in to the other company
            location.reload()
          else
            @collection.fetch()

  changeCompany: (event) ->
    subdomain = @model.get('subdomain')
    app.utils.switchToCompany(subdomain, true)

  isCurrentCompany: ->
    @model.id is @currentCompany.id
