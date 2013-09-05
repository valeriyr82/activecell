require 'spec_helper'

describe Api::V1::CompaniesController, 'routing' do

  specify do
    get('/api/v1/companies').should route_to('api/v1/companies#index')
  end

  specify do
    get('/api/v1/companies/1').should route_to('api/v1/companies#show', id: '1')
  end

  specify do
    post('/api/v1/companies').should route_to('api/v1/companies#create')
  end

  specify do
    put('/api/v1/companies/1').should route_to('api/v1/companies#update', id: '1')
  end

  specify do
    put('/api/v1/companies/1/upgrade').should route_to('api/v1/companies#upgrade', id: '1')
  end

  specify do
    put('/api/v1/companies/1/downgrade').should route_to('api/v1/companies#downgrade', id: '1')
  end

  specify do
    delete('/api/v1/companies/1').should route_to('api/v1/companies#destroy', id: '1')
  end

  specify do
    put('/api/v1/companies/1/invite_user').should route_to('api/v1/companies#invite_user', id: '1')
  end
  
  specify do
    put('/api/v1/companies/1/remove_user').should route_to('api/v1/companies#remove_user', id: '1')
  end

  specify do
    post('/api/v1/companies/1/create_advised_company').should route_to('api/v1/companies#create_advised_company', id: '1')
  end
  
  specify do
    put('/api/v1/companies/1/invite_advisor').should route_to('api/v1/companies#invite_advisor', id: '1')
  end

  specify do
    put('/api/v1/companies/1/remove_advised_company').should route_to('api/v1/companies#remove_advised_company', id: '1')
  end

end
