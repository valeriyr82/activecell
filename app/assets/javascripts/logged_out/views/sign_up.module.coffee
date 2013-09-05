SubdomainGenerator = require('lib/subdomain_generator')

module.exports = class SignUp extends Backbone.View
  el: 'form#sign-up'

  events:
    'keyup input.company-name': 'generateSuggestedSubdomain'

  initialize: ->
    @events = {} if @$el.length is 0
    @disableCompanyFields() if $("#t").val() != ''

  generateSuggestedSubdomain: (event) ->
    return if @$('#sign_up_form_company_subdomain[readonly]').length > 0
    event.preventDefault()

    name = @$('input.company-name').val()
    generator = new SubdomainGenerator(name)
    @$('input.company-subdomain').val(generator.generate())

  disableCompanyFields: ->
    $('#sign_up_form_company_name, #sign_up_form_company_subdomain, #sign_up_form_user_email').
      addClass('disabled').prop('readonly', true)
