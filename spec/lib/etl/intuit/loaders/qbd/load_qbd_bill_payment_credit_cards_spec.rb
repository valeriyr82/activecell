require 'spec_helper'

describe 'load_qbd_bill_payment_credit_cards' do
  include_context 'intuit extraction setup', 'load_qbd_bill_payment_credit_cards'
  include_context 'stubbed processors for intuit'
  
  before do
    engine.process batch
  end

  it "should fill database with FinancialTransactions from response" do
    pending "This test can't be implemented until we have response with some credit card payments"
  end
end
