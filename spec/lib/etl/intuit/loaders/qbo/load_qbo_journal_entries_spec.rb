require 'spec_helper'

describe 'load_qbo_journal_entries' do
  include_context 'quickbooks online extraction setup', 'load_qbo_journal_entry'
  include_context 'stubbed processors for qbo'

  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    it "should associate FinancialTransactions with company" do
      all = FinancialTransaction.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all FinancialTransactions have correct company_id"
    end
    
    it "should fill database with FinancialTransactions from response" do
      FinancialTransaction.count.should == 76
    end
    
    context 'When looking at a single created transaction' do
      shared_examples_for "transaction from qbo journal entry" do
        specify 'loaded transaction' do
          expect(subject.source).to eq('qbo_journal_entry')
          expect(subject.vendor_id).to eq(vendor.id)
          expect(subject.period_id).to eq(Period.first.id)
          expect(subject.account_id).to eq(account.id)
          expect(subject.product_id).to eq(product.id)
          expect(subject.customer_id).to eq(customer.id)
          expect(subject.status).to be_nil
        end
      end
      
      describe 'for a charge record' do
        subject { FinancialTransaction.find_by(qbo_id: "1467-264", company_id: company.id, amount_cents: 24144) }

        specify 'loaded transaction' do
          expect(subject.transaction_date).to eq(Date.parse('2011-10-28'))
          expect(subject.is_credit).to be_false
        end
        it_behaves_like "transaction from qbo journal entry"
      end
    
      describe 'for a gain record' do
        subject { FinancialTransaction.find_by(qbo_id: "863-172", company_id: company.id, amount_cents: -1850461) }

        specify 'loaded transaction' do
          expect(subject.transaction_date).to eq(Date.parse('2011-05-31'))
          expect(subject.is_credit).to be_true
        end
        it_behaves_like "transaction from qbo journal entry"
      end
    end
  end
  
  context 'When there are FinancialTransactions in the db' do
    let!(:mentioned_transaction) { create(:financial_transaction, qbo_id: '863-172', source: "qbo_journal_entry",
        account: account, company: company, is_credit: true, amount_cents: -10) }
    let!(:not_mentioned_transaction) { create(:financial_transaction, qbo_id: "someNonExistingId", account: account,
        company: company, source: "qbo_journal_entry", is_credit: true) }
    
    before { engine.process batch }
    
    it 'should update the one with same qbo_id and company' do
      mentioned_transaction.reload.amount_cents.should == -1850461
    end
    
    it "should remove all of items not mentioned in the response" do
      lambda{ not_mentioned_transaction.reload.id }.should raise_error Mongoid::Errors::DocumentNotFound
    end
  end
end
