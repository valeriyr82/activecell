require 'spec_helper'

describe 'load_qbo_checks' do
  include_context 'quickbooks online extraction setup', 'load_qbo_check'
  include_context 'stubbed processors for qbo'

  context 'without already existing financial transactions in the db' do
    before do
      FinancialTransaction.delete_all
      engine.process batch
    end

    it "should associate FinancialTransactions with company" do
      all = FinancialTransaction.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all FinancialTransactions have correct company_id"
    end
    
    it "should fill database with FinancialTransactions from response" do
      FinancialTransaction.count.should == 100
    end
    
    it "should create unique qbo_id for each pair of created financial transactions" do
      ids = FinancialTransaction.all.map &:qbo_id
      ids.uniq.size.should == FinancialTransaction.count / 2
    end
    
    describe 'When looking at a single created transaction' do
      let(:period){ Period.first }
        
      subject { FinancialTransaction.find_by(qbo_id: "1156-2", company_id: company.id, is_credit: false) }

      specify 'loaded transaction' do
        expect(subject.amount_cents).to eq(50596)
        expect(subject.source).to eq('qbo_check')
        expect(subject.transaction_date).to eq(Date.parse("2011-08-09"))
        expect(subject.vendor_id).to eq(vendor.id)
        expect(subject.period_id).to eq(period.id)
        expect(subject.account_id).to eq(account.id)
        expect(subject.product_id).to eq(product.id)
        expect(subject.customer_id).to eq(customer.id)
        expect(subject.status).to be_nil
      end
    end
  end
  
  context 'with financial transactions in the db' do
    let!(:mentioned_transaction) { create(:financial_transaction, qbo_id: '1156-2', source: 'qbo_check',
        account: account, company: company, is_credit: true, amount_cents: 10) }
    let!(:not_mentioned_transaction) { create(:financial_transaction, qbo_id: "someNonExistingId", account: account, 
        company: company, source: 'qbo_check', is_credit: true) }
    
    before { engine.process batch }

    it "should update an existing transaction" do
      mentioned_transaction.reload.amount_cents.should == -50596
    end
    
    it "should delete existing transactions not mentioned in the received data" do
      lambda{ not_mentioned_transaction.reload.account_id }.should raise_error Mongoid::Errors::DocumentNotFound
    end
  end
end
