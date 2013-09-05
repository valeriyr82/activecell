require 'spec_helper'

describe Api::V1::UsersController, 'routing' do

  specify do
    get('/api/v1/users').should route_to('api/v1/users#index')
  end

  specify do
    get('/api/v1/users/1').should route_to('api/v1/users#show', id: '1')
  end

  specify do
    put('/api/v1/users/1').should route_to('api/v1/users#update', id: '1')
  end

  specify do
    put('/api/v1/users/1/update_password').should route_to('api/v1/users#update_password', id: '1')
  end

end
