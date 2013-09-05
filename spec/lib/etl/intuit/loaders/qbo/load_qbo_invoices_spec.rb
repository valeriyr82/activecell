require 'spec_helper'

describe 'load_qbo_invoices' do
  include_context 'quickbooks online extraction setup', 'load_qbo_invoice'
  include_context 'stubbed processors for qbo'
  
  context 'without already existing financial transactions in the db' do
    let!(:ar_account) { create(:account, company: company, sub_type: 'Accounts Receivable')}
    
    before do
      ETL::QBO.stub(:get_product_inc_account_lookup).and_return(stub(transform: account.id))
      ETL::QBO.stub(:get_default_ar_account).and_return(ar_account.id)
      FinancialTransaction.delete_all
      engine.process batch
    end

    it "should associate FinancialTransactions with company" do
      all = FinancialTransaction.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all FinancialTransactions have correct company_id"
    end
    
    it "should assign qbo_id to each of financial transaction" do
      all = FinancialTransaction.all.all? { |f| !f.qbo_id.nil? }
      all.should be_true
    end
    
    it "should fill database with FinancialTransactions from response" do
      FinancialTransaction.count.should == 142
    end
    
    describe 'When looking at a single created transaction' do
      let(:period) { Period.first}
        
      subject { FinancialTransaction.find_by(company_id: company.id, is_credit: true, amount_cents: -4163)}

      specify 'loaded transaction' do
        expect(subject.qbo_id).to include('1094')
        expect(subject.qbo_id).not_to eq('1094')
        expect(subject.source).to eq('qbo_invoice')
        expect(subject.transaction_date).to eq(Date.parse("2012-06-21"))
        expect(subject.vendor_id).to eq(vendor.id)
        expect(subject.period_id).to eq(period.id)
        expect(subject.account_id).to eq(ar_account.id)
        expect(subject.product_id).to eq(product.id)
        expect(subject.customer_id).to eq(customer.id)
        expect(subject.status).to eq(nil)
      end
    end
  end
  
  context 'with financial transactions in the db' do
    let!(:not_mentioned_transaction) { create(:financial_transaction, qbo_id: "1094", account: account, 
        company: company, source: 'qbo_invoice', is_credit: true) }
    
    before do
      ETL::QBO.stub(:get_product_inc_account_lookup).and_return(stub(transform: account.id))
      ETL::QBO.stub(:get_default_ar_account).and_return(account.id)
      engine.process batch
    end
    
    it "should delete existing transactions not mentioned in the received data" do
      lambda { not_mentioned_transaction.reload.account_id }.should raise_error Mongoid::Errors::DocumentNotFound
    end
  end
  
end
