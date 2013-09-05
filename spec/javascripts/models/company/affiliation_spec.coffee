CompanyAffiliation = require('models/company/affiliation')

describe 'CompanyAffiliation', ->
  beforeEach ->
    @model = new CompanyAffiliation()

  it 'has valid #paramRoot', ->
    expect(@model.paramRoot).toEqual 'company_affiliation'

  it 'has valid #urlRoot', ->
    expect(@model.urlRoot).toEqual 'api/v1/company/affiliations'
