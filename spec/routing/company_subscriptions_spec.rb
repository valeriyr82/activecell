require 'spec_helper'

describe CompanySubscriptionsController, "routing", :billing do

  specify do
    post('/company_subscriptions').should route_to('company_subscriptions#create')
  end

  specify do
    get('/company_subscriptions/new').should route_to('company_subscriptions#new')
  end

  specify do
    get('/company_subscriptions/edit').should route_to('company_subscriptions#edit')
  end

  specify do
    post('/company_subscriptions/update_billing_info').should route_to('company_subscriptions#update_billing_info')
  end

  specify do
    put('/company_subscriptions/upgrade').should route_to('company_subscriptions#upgrade')
  end

  specify do
    put('/company_subscriptions/cancel').should route_to('company_subscriptions#cancel')
  end
end
