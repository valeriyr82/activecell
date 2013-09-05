Company = require('models/company')
User    = require('models/user')

describe 'Company', ->
  beforeEach ->
    @model = new Company(name: 'Test company', url: 'http://test.com', user_ids: [123, 234])
    
  describe '#isAdvisor', ->
    it 'should return true is a company is advisor', ->
      expect(@model.isAdvisor()).toBeFalsy()

      @model.set('_type', 'AdvisorCompany')
      expect(@model.isAdvisor()).toBeTruthy()

  describe '#isAdvised', ->
    it 'should return true is a company is advised', ->
      @model.set('is_advised', false)
      expect(@model.isAdvised()).toBeFalsy()

      @model.set('is_advised', true)
      expect(@model.isAdvised()).toBeTruthy()

  describe '#isTrialExpired', ->
    it 'should return true is a company is advised', ->
      @model.set('is_trial_expired', false)
      expect(@model.isTrialExpired()).toBeFalsy()

      @model.set('is_trial_expired', true)
      expect(@model.isTrialExpired()).toBeTruthy()

  describe '#toggleAdvisor', ->
    beforeEach ->
      spyOn($, 'ajax').andCallFake (options) ->
        options.success()
        
    describe 'when the company is not an advisor', ->
      beforeEach ->
        @model.set('_type', 'Company')
        @model.toggleAdvisor()

      it 'should set type to AdvisorCompany', ->
        expect(@model.get('_type')).toEqual('AdvisorCompany')
        expect(@model.isAdvisor()).toBeTruthy()

    describe 'when the company is an advisor', ->
      beforeEach ->
        @model.set('_type', 'AdvisorCompany')
        @model.toggleAdvisor()

      it 'should set type to Company', ->
        expect(@model.get('_type')).toEqual('Company')
        expect(@model.isAdvisor()).toBeFalsy()

  describe '#removeAdvisedCompany', ->
    beforeEach ->
      app.company.id = 123
      spyOn($, 'ajax').andCallFake (options) ->
        options.success()
      
    describe 'on success', ->
      beforeEach ->
        @companyToRemove = new Company(id: 234)
        @companyToRemove.removeAdvisedCompany()

      it 'should send id of company to be removed', ->
        request = $.ajax.mostRecentCall.args[0]
        expect(request.data).toEqual(company: id: 234)
        
      it 'should contain id of current company in the url', ->
        request = $.ajax.mostRecentCall.args[0]
        expect(request.url).toContain('/companies/' + app.company.id)
  
  describe '#removeUser', ->
    beforeEach ->
      spyOn($, 'ajax').andCallFake (options) ->
        options.success()
      @user = new User(id: 123)
      @model.set("user_ids_count", 2);
      @model.removeUser(@user)

    describe 'on success', ->
      it 'should decrease user_ids counter', ->
        expect(@model.getUserIds()).toEqual 1

      it 'should send id of user/company to be removed', ->
        request = $.ajax.mostRecentCall.args[0]
        expect(request.data).toEqual(user: id: 123)
        
        
        
