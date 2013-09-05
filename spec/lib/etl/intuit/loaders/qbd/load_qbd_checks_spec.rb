require 'spec_helper'

describe 'load_qbd_checks' do
  include_context 'intuit extraction setup', 'load_qbd_checks'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    # 16 is an expected amount of created financial transaction records  
    it_behaves_like 'financial transactions records created from report', 16
  
    it_behaves_like 'a correctly created financial transaction', 
      {qbd_id: "8376", date: '2012-03-05', status: 'Payable', source: 'qbd_check', cents: 117098}
  end
  
  context 'When there are FinancialTransactions in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "8376", source: 'qbd_check'}
    before { engine.process batch }
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: -117098
  end
end

