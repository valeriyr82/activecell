require 'spec_helper'

describe 'load_qbd_vendor_credits' do
  include_context 'intuit extraction setup', 'load_qbd_vendor_credits'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    it "should fill database with FinancialTransactions from response" do
      pending "This test can't be implemented until we have response with some vendor credits"
    end
  end
end

