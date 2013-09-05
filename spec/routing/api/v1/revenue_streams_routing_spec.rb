require 'spec_helper'

describe Api::V1::RevenueStreamsController, 'routing' do

  specify do
    post('/api/v1/revenue_streams').should route_to('api/v1/revenue_streams#create')
  end

  specify do
    put('/api/v1/revenue_streams/1').should route_to('api/v1/revenue_streams#update', id: '1')
  end

  specify do
    delete('/api/v1/revenue_streams/1').should route_to('api/v1/revenue_streams#destroy', id: '1')
  end

end
