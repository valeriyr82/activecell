require 'spec_helper'

describe 'load_qbd_sales_receipts' do
  include_context 'intuit extraction setup', 'load_qbd_sales_receipts'
  include_context 'stubbed processors for intuit'
  
  before do
    # caused by: 
    # after_read  :qbd_rev_account_from_item, {posting_type: :credit}
    ETL::QBD.stub(:get_product_inc_account_lookup).times.and_return(stub(transform: account))
  end
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    # 24 is an expected amount of created financial transaction records  
    it_behaves_like 'financial transactions records created from report', 24

    it_behaves_like 'a correctly created financial transaction', 
      {qbd_id: "8146", date: '2012-01-02', status: "Payable", source: 'qbd_sales_receipt', cents: -999}
  end
  
  context 'When there are FinancialTransactions in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "8154", source: 'qbd_sales_receipt'}
    before { engine.process batch }
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: -4999
  end
  
end
