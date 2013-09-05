require 'spec_helper'

describe 'load_qbd_deposits' do
  include_context 'intuit extraction setup', 'load_qbd_deposits'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    # 16 is an expected amount of created financial transaction records  
    it_behaves_like 'financial transactions records created from report', 16

    it_behaves_like 'a correctly created financial transaction', 
      {qbd_id: "8388: 8143", date: '2012-01-06', status: nil, source: 'qbd_deposit', cents: 4355}
  end
  
  context 'When there are FinancialTransactions in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "8362: 8180", source: 'qbd_deposit'}
    before { engine.process batch }
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: -4999
  end
end
