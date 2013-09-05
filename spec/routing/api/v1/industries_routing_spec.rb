require 'spec_helper'

describe Api::V1::IndustriesController, 'routing' do

  specify do
    get('/api/v1/industries').should route_to('api/v1/industries#index')
  end

end
