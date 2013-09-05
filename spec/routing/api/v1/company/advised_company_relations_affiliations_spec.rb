require 'spec_helper'

describe Api::V1::Company::AdvisedCompanyAffiliationsController, 'routing' do

  specify do
    path = api_v1_advised_company_affiliations_path

    expect(path).to eq('/api/v1/company/advised_company_affiliations')
    get(path).should route_to('api/v1/company/advised_company_affiliations#index')
  end

  specify do
    path = api_v1_advised_company_affiliation_path(':id')

    expect(path).to eq('/api/v1/company/advised_company_affiliations/:id')
    put(path).should route_to('api/v1/company/advised_company_affiliations#update', id: ':id')
  end

end
