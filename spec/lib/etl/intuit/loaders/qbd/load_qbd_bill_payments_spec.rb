require 'spec_helper'

describe 'load_qbd_bill_payments' do
  include_context 'intuit extraction setup', 'load_qbd_bill_payments'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before do
      engine.process batch
    end

    # 10 is an expected amount of created financial transaction records  
    it_behaves_like 'financial transactions records created from report', 10
  
    it_behaves_like 'a correctly created financial transaction', 
      {qbd_id: "7664", date: '2012-03-13', status: 'Paid', source: 'qbd_bill_payment', cents: 4350}
  end 
  
  context 'When there are FinancialTransactions in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "7664", source: 'qbd_bill_payment'}
    before do
      engine.process batch
    end
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: -4350
  end
end
