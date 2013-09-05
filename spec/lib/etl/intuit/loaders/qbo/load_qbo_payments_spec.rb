require 'spec_helper'

describe 'load_qbo_payments' do
  include_context 'quickbooks online extraction setup', 'load_qbo_payment'
  include_context 'stubbed processors for qbo'

  context 'When there are no FinancialTransactions in the db yet' do
    before do
      ETL::QBO.stub(:get_default_ar_account).and_return(account.id)
      ETL::QBO.stub(:get_default_exp_account).and_return(account.id)
      engine.process batch
    end

    context 'When looking at a single created transaction' do
      shared_examples_for "transaction from payment" do
        specify 'loaded transaction' do
          expect(subject.source).to eq('qbo_payment')
          expect(subject.transaction_date).to eq(Date.parse('2012-06-21'))
          expect(subject.vendor_id).to eq(vendor.id)
          expect(subject.period_id).to eq(Period.first.id)
          expect(subject.account_id).to eq(account.id)
          expect(subject.product_id).to eq(product.id)
          expect(subject.customer_id).to eq(customer.id)
          expect(subject.status).to be_nil
        end
      end
      
      describe 'for a charge record' do
        subject { FinancialTransaction.find_by(qbo_id: "1094", company_id: company.id, amount_cents: 4163) }

        its(:is_credit) { should == false }
        it_behaves_like "transaction from payment"
      end
    
      describe 'for a gain record' do
        subject { FinancialTransaction.find_by(qbo_id: "1094", company_id: company.id, amount_cents: -4163) }

        its(:is_credit) { should == true }
        it_behaves_like "transaction from payment"
      end
    end

    it "should create unique qbo_id for each pair of created financial transactions" do
      ids = FinancialTransaction.all.map &:qbo_id
      ids.uniq.size.should == FinancialTransaction.count / 2
    end
    
    it_behaves_like 'financial transactions records created from report', 60, 'qbo'
  end
  
  context 'When there are FinancialTransactions in the db' do
    let!(:mentioned_transaction) { create(:financial_transaction, qbo_id: '1094', source: 'qbo_payment',
        account: account, company: company, is_credit: true, amount_cents: -10) }
    let!(:not_mentioned_transaction) { create(:financial_transaction, qbo_id: "someNonExistingId", account: account,
        company: company, source: "qbo_payment", is_credit: true) }
    
    before do
      ETL::QBO.stub(:get_default_ar_account).and_return(account.id)
      ETL::QBO.stub(:get_default_exp_account).and_return(account.id)
      engine.process batch
    end
    
    it 'should update the one with same qbo_id and company' do
      mentioned_transaction.reload.amount_cents.should == -4163
    end
    
    it "should remove all of items not mentioned in the response" do
      expect do
        not_mentioned_transaction.reload.id
      end.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end
end
