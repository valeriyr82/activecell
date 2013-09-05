require 'spec_helper'

describe IntuitCompaniesController, "routing" do

  specify do
    auth_intuit_callback_path.should == '/auth/intuit/callback'
  end

  specify do
    get(callback_intuit_company_path).should route_to('intuit_companies#callback')
  end

  specify do
    get(proxy_intuit_company_path).should route_to('intuit_companies#proxy')
  end

  specify do
    put(disconnect_intuit_company_path).should route_to('intuit_companies#disconnect')
  end

end
