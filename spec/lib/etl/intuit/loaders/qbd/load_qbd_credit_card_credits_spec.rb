require 'spec_helper'

describe 'load_qbd_credit_card_credits' do
  include_context 'intuit extraction setup', 'load_qbd_credit_card_credits'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    # 28 is an expected amount of created financial transaction records  
    it_behaves_like 'financial transactions records created from report', 28

    it_behaves_like 'a correctly created financial transaction', 
      {qbd_id: "8124", date: '2012-02-28', status: 'Payable', source: 'qbd_credit_card_credit', cents: 330356}
  end
  
  context 'When there are FinancialTransactions in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "8124", source: 'qbd_credit_card_credit'}
    before { engine.process batch }
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: -330356
  end
  
end
