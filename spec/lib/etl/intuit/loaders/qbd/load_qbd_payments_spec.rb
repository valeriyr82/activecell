require 'spec_helper'

describe 'load_qbd_payments' do
  include_context 'intuit extraction setup', 'load_qbd_payments'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    it_behaves_like 'financial transactions records created from report', 16
    it_behaves_like 'a correctly created financial transaction', 
      {qbd_id: "2273", date: '2010-11-05', status: "Paid", source: 'qbd_payment', cents: 6495}
  end
  
  context 'When there are FinancialTransactions in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "2864", source: 'qbd_payment'}
    before { engine.process batch }
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: -4999
  end
  
end
