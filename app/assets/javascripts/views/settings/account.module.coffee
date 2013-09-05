BaseView                = require('views/shared/base_view')
NewSubscriptionOptions  = require('models/recurly/new_subscription_options')
EditSubscriptionOptions = require('models/recurly/edit_subscription_options')

module.exports = class Account extends BaseView
  template: JST['settings/account']

  events:
    'click .btn.subscribe-button.monthly': 'renderSubscribeMonthlyForm'
    'click .btn.subscribe-button.annual': 'renderSubscribeAnnualForm'
    'click .btn.subscribe-button.advisor-annual': 'renderSubscribeAdvisorAnnualForm'
    'click #recurly-subscription-form .footer .btn.cancel': 'hideRecurlyForm'

    'click .btn.downgrade-subscription-button': 'downgradeSubscription'
    'click .btn.upgrade-button': 'upgradeAccount'
    'click .btn.cancel-account-button': 'cancelAccount'

  initialize: ->
    { @subscriber, @company } = app
    @addEvent @subscriber, 'change', @render

  render: =>
    @$el.html @template(@_templateContext())
    @renderBillingInfoForm() if @subscriber.hasActiveSubscription()
    @

  _templateContext: ->
    subscriber: @subscriber, subscription: @subscriber.getSubscription()
    isInTrial: @company.isInTrial()
    isTrialExpired: @company.isTrialExpired()
    trialDaysLeft: @company.trialDaysLeft()
    isAdvised: @company.isAdvised()

  # Makes JSONP call to recurly and renders subscribe form
  renderSubscribeMonthlyForm: (event) ->
    event?.preventDefault()
    @_renderSubscriptionForm('monthly')

  renderSubscribeAnnualForm: (event) ->
    event?.preventDefault()
    @_renderSubscriptionForm('annual')

  renderSubscribeAdvisorAnnualForm: (event) ->
    event?.preventDefault()
    @_renderSubscriptionForm('advisor_annual')

  _renderSubscriptionForm: (planCode) ->
    @loadingForm()

    subscriptionOptions = new NewSubscriptionOptions(plan_code: planCode)
    subscriptionOptions.fetch
      success: =>
        Recurly.config(subscriptionOptions.getConfig())

        options = subscriptionOptions.buildOptions
          target: '#recurly-subscription-form'
          enableAddOns: false
          afterInject: =>
            @injectCancelButton()
            @hideSubscriptionPlans()
            @$('#recurly-subscription-form-container').show()
        options.account = {
          firstName : app.user.get('name').split(' ')[0] if app.user.get('name')
          lastName  : app.user.get('name').split(' ')[1] if app.user.get('name') and app.user.get('name').split(' ').length > 1
          email     : app.user.get('email') if app.user.get('email')
        }
        options.billingInfo = {
          address1 : app.company.get('address_1') if app.company.get('address_1')
          address2 : app.company.get('address_2') if app.company.get('address_2')
          zip      : app.company.get('postal_code') if app.company.get('postal_code')
          country  : app.company.get('country_id') if app.company.get('country_id')
        }
        Recurly.buildSubscriptionForm(options)

  renderBillingInfoForm: (event) ->
    event?.preventDefault()

    billingInfoOptions = new EditSubscriptionOptions()
    billingInfoOptions.fetch
      success: =>
        Recurly.config(billingInfoOptions.getConfig())

        options = billingInfoOptions.buildOptions
          target: '#recurly-edit-subscription-form'
          afterInject: =>
            @$('#recurly-subscription-form-container').show()

        Recurly.buildBillingInfoUpdateForm(options)

  toggleAdvisor: (event) ->
    event?.preventDefault()
    app.company.toggleAdvisor
      success: (company) =>
        if company.isAdvisor()
          app.settingsAdvisor()

  hideRecurlyForm: ->
    @$('#recurly-subscription-form form.recurly').remove()
    @$('#recurly-subscription-form-container').hide()

    @showSubscriptionPlans()
    @$('.subscribe-button').removeClass('disabled')

  downgradeSubscription: (event) ->
    event?.preventDefault()

    bootbox.confirm 'Are you sure?', (confirmed) =>
      return unless confirmed

      $.ajax
        type: 'PUT'
        url: '/company_subscriptions/cancel'
        success: => @subscriber.set('subscription_is_cancelled?', true)

  upgradeAccount: (event) ->
    event?.preventDefault()
    planCode = $(event.target).data('plan-code')

    upgradingPossible = planCode == 'annual' and @subscriber.canUpgrade()
    downgradingPossible = planCode == 'monthly' and @subscriber.canDowngrade()
    return if not (upgradingPossible or downgradingPossible)

    bootbox.confirm 'Are you sure?', (confirmed) =>
      return unless confirmed

      @subscriber.changePlanTo planCode,
        success: =>
          location.reload()
        error: =>

  cancelAccount: (event) ->
    event?.preventDefault()

    bootbox.confirm 'Are you sure you wish to cancel your account? This cannot be undone.', (confirmed) =>
      return unless confirmed

      @company.destroy
        success: -> location.reload()

  loadingForm: ->
    @$('.subscribe-button').addClass('disabled')

  hideSubscriptionPlans: ->
    @$('.subscription-plans').hide()

  showSubscriptionPlans: ->
    @$('.subscription-plans').show()

  injectCancelButton: ->
    @$('#recurly-subscription-form .footer').append('<a class="cancel btn btn-large btn-inverse">Cancel</a>')
