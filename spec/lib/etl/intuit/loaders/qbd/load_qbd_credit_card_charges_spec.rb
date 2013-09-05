require 'spec_helper'

describe 'load_qbd_credit_card_charges' do
  include_context 'intuit extraction setup', 'load_qbd_credit_card_charges'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    # 18 is an expected amount of created financial transaction records  
    it_behaves_like 'financial transactions records created from report', 18

    it_behaves_like 'a correctly created financial transaction', 
      {qbd_id: "8136", date: '2012-01-16', status: 'Payable', source: 'qbd_credit_card_charge', cents: 293483}
  end
  
  context 'When there are FinancialTransactions in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "8136", source: 'qbd_credit_card_charge'}
    before { engine.process batch }
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: -293483
  end
  
end
