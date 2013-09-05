require 'spec_helper'

describe Api::V1::BackgroundJobsController, 'routing', :background_jobs do

  specify do
    post('/api/v1/background_jobs').should route_to('api/v1/background_jobs#create')
  end

  specify do
    get('/api/v1/background_jobs/last').should route_to('api/v1/background_jobs#last')
  end

  specify do
    get('/api/v1/background_jobs/1').should route_to('api/v1/background_jobs#show', id: '1')
  end

end
