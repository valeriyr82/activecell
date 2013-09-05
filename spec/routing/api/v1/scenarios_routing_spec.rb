require 'spec_helper'

describe Api::V1::ScenariosController, 'routing' do

  specify do
    get('/api/v1/scenarios').should route_to('api/v1/scenarios#index')
  end

  specify do
    get('/api/v1/scenarios/1').should route_to('api/v1/scenarios#show', id: '1')
  end

  specify do
    post('/api/v1/scenarios').should route_to('api/v1/scenarios#create')
  end

  specify do
    put('/api/v1/scenarios/1').should route_to('api/v1/scenarios#update', id: '1')
  end

  specify do
    delete('/api/v1/scenarios/1').should route_to('api/v1/scenarios#destroy', id: '1')
  end

end
