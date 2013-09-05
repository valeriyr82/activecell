require 'spec_helper'

describe 'load_qbd_credit_memos' do
  include_context 'intuit extraction setup', 'load_qbd_credit_memos'
  include_context 'stubbed processors for intuit'
  
  before do
    # caused by: 
    # after_read  :qbd_rev_account_from_item, {posting_type: :credit}
    ETL::QBD.should_receive(:get_product_inc_account_lookup).exactly(2).times.and_return(stub(transform: account))
  end
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    # 4 is an expected amount of created financial transaction records  
    it_behaves_like 'financial transactions records created from report', 4
    
    it_behaves_like 'a correctly created financial transaction', 
      {qbd_id: "8207", date: '2012-01-31', status: 'Paid', source: 'qbd_credit_memo', cents: -2997}
  end
  
  context 'When there are FinancialTransactions in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "8207", source: 'qbd_credit_memo'}
    before { engine.process batch }
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: 2997
  end
  
end
