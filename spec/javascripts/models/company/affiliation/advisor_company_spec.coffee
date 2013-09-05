AdvisorCompanyAffiliation = require('models/company/affiliation/advisor_company')

describe 'AdvisorCompanyAffiliation', ->
  beforeEach ->
    @model = new AdvisorCompanyAffiliation
      advisor_company:
        name: 'Advisor Company'
        logo_url: 'http://this.is.a.logo.url'

  describe '#getType', ->
    it 'should return "company"', ->
      expect(@model.getType()).toEqual 'company'

  describe '#getName', ->
    it 'should return corresponing advisor company #name', ->
      expect(@model.getName()).toEqual 'Advisor Company'

  describe '#getEmail', ->
    it 'should return nothing', ->
      expect(@model.getEmail()).toBeUndefined()

  describe '#getAvatarUrl', ->
    it 'should return company logo url', ->
      expect(@model.getAvatarUrl()).toEqual 'http://this.is.a.logo.url'
