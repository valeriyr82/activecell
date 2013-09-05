require 'spec_helper'

describe Api::V1::Company::AffiliationsController, 'routing' do

  specify do
    path = api_v1_company_affiliations_path

    expect(path).to eq('/api/v1/company/affiliations')
    get(path).should route_to('api/v1/company/affiliations#index')
  end

  specify do
    path = api_v1_company_affiliation_path(':id')

    expect(path).to eq('/api/v1/company/affiliations/:id')
    put(path).should route_to('api/v1/company/affiliations#update', id: ':id')
  end

end
