require 'spec_helper'

describe 'load_qbo_payments' do
  include_context 'quickbooks online extraction setup', 'load_qbo_sales_receipt'
  include_context 'stubbed processors for qbo'

  context 'When there are no FinancialTransactions in the db yet' do
    before do
      ETL::QBO.stub(:get_product_inc_account_lookup).and_return(stub(transform: account))
      engine.process batch
    end

    context 'When looking at a single created transaction' do
      let(:both_transactions) { FinancialTransaction.where(qbo_id: "1531-5", company_id: company.id) }
      let(:credit_t) { both_transactions.detect { |ft| ft.is_credit } }
      let(:debit_t) { both_transactions.detect { |ft| !ft.is_credit } }

      shared_examples_for "transaction from sales receipt" do
        specify do
          expect(subject.source).to eq('qbo_sales_receipt')
          expect(subject.vendor_id).to eq(vendor.id)
          expect(subject.period_id).to eq(Period.first.id)
          expect(subject.account_id).to eq(account.id)
          expect(subject.product_id).to eq(product.id)
          expect(subject.customer_id).to eq(customer.id)
          expect(subject.status).to be_nil
        end
      end
      
      context 'credit transaction' do
        subject { credit_t }

        specify do
          expect(subject.is_credit).to eq(true)
          expect(subject.transaction_date).to eq(Date.parse('2011-12-01'))
          expect(subject.amount_cents).to eq(-355)
        end
        it_behaves_like "transaction from sales receipt"
      end
      
      context 'debit transaction' do
        subject { debit_t }

        specify do
          expect(subject.is_credit).to eq(false)
          expect(subject.amount_cents).to eq(355)
          expect(subject.transaction_date).to eq(Date.parse('2011-12-01'))
        end
        it_behaves_like "transaction from sales receipt"
      end
    end
    
    it "should create FinancialTransaction for each line node" do
      %w(1531-5 1531-8 1531-7).each do |qbo_id|
        ft = FinancialTransaction.where(qbo_id: qbo_id).to_a
        ft.should_not be_empty
        ft.size.should == 2
      end
    end
    
    it "should associate FinancialTransactions with company" do
      all = FinancialTransaction.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all FinancialTransactions have correct company_id"
    end
    
    it "should fill database with FinancialTransactions from response" do
      FinancialTransaction.count.should == 88
    end
    
    it "should create unique qbo_id for each pair of created financial transactions" do
      ids = FinancialTransaction.all.map &:qbo_id
      ids.uniq.size.should == FinancialTransaction.count / 2
    end
  end
  
  context 'When there are FinancialTransactions in the db' do
    let!(:mentioned_transaction) { create(:financial_transaction, qbo_id: '1531-5', source: 'qbo_sales_receipt',
        account: account, company: company, is_credit: true, amount_cents: -10) }
    let!(:not_mentioned_transaction) { create(:financial_transaction, qbo_id: "someNonExistingId", account: account,
        company: company, source: "qbo_sales_receipt", is_credit: true) }
      
    before do
      ETL::QBO.stub(:get_product_inc_account_lookup).and_return(stub(transform: account))
      engine.process batch
    end
      
    it 'should update the one with same qbo_id and company' do
      mentioned_transaction.reload.amount_cents.should == -355
    end
      
    it "should remove all of items not mentioned in the response" do
      lambda{ not_mentioned_transaction.reload.id }.should raise_error Mongoid::Errors::DocumentNotFound
    end
  end
end
