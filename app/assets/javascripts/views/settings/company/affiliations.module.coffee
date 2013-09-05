BaseView = require('views/shared/base_view')
Users = require('collections/users')
CompanyAffiliations = require('collections/company/affiliations')

AdvisorUpgradeView = require('views/settings/shared/advisor_upgrade')
SettingsCompanyAffiliation = require('views/settings/company/affiliation')
SettingsCompanyInvitations = require('views/settings/company/invitations')

module.exports = class SettingsCompanyAffiliations extends BaseView
  template: JST['settings/company/affiliations']

  initialize: ->
    @collection = new CompanyAffiliations()
    @collection.fetch()
    @addEvent @collection, 'reset', @renderUsers

  render: =>
    @$el.html @template(isAdvised: @model.isAdvised())

    @renderInvitations()
    @renderAdvisorBox() if not @model.isAdvised()
    @

  renderUsers: ->
    @collection.each (affiliation) =>
      userView = @createView SettingsCompanyAffiliation, model: affiliation
      @$el.find('table.users tbody').append(userView.render().el)

  renderInvitations: ->
    invitationsView = @createView SettingsCompanyInvitations, collection: @collection
    @$('#company-invitations').html invitationsView.render().el

  renderAdvisorBox: ->
    advisorView = @createView AdvisorUpgradeView
    @$('#advisor-box').html advisorView.render().el
