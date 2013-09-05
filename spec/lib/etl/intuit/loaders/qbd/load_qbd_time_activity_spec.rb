require 'spec_helper'

describe 'load_qbd_time_activity' do
  include_context 'intuit extraction setup', 'load_qbd_time_activity'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    it "should fill database with FinancialTransactions from response" do
      pending "This test can't be implemented until we have response with some time activity"
    end  
  end
end

