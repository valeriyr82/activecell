require 'spec_helper'

describe 'load_qbd_bills' do
  include_context 'intuit extraction setup', 'load_qbd_bills'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    # 8 is an expected amount of created financial transaction records
    it_behaves_like 'financial transactions records created from report', 8
    
    it_behaves_like 'a correctly created financial transaction', 
      {qbd_id: "7669", date: '2012-03-05', status: 'Paid', source: 'qbd_bill', cents: 391000}

  end
  
  context 'When some bills already in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "7669", source: 'qbd_bill'}
    before { engine.process batch }
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: -391000
  end
end
