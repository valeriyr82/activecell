require 'spec_helper'

describe 'load_qbd_journal_entries' do
  include_context 'intuit extraction setup', 'load_qbd_journal_entries'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    it "should associate FinancialTransactions with company" do
      all = FinancialTransaction.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all FinancialTransactions have correct company_id"
    end
    
    it "should fill database with FinancialTransactions from response" do
      FinancialTransaction.count.should == 4
    end
    
    context 'When looking at a single created transaction' do
      shared_examples_for "transaction from qbd journal entry" do
        specify 'loaded transaction' do
          expect(subject.source).to eq('qbd_journal_entry')
          expect(subject.transaction_date).to eq(Date.parse('2013-01-01'))
          expect(subject.vendor_id).to eq(vendor.id)
          expect(subject.period_id).to eq(Period.first.id)
          expect(subject.account_id).to eq(account.id)
          expect(subject.product_id).to eq(product.id)
          expect(subject.customer_id).to eq(customer.id)
          expect(subject.status).to be_nil
        end
      end
      
      describe 'for a charge record' do
        subject { FinancialTransaction.find_by(qbd_id: "4023", company_id: company.id) }

        specify 'loaded transaction' do
          expect(subject.amount_cents).to eq(7079)
          expect(subject.is_credit).to be_false
        end
        it_behaves_like "transaction from qbd journal entry"
      end
    
      describe 'for a gain record' do
        subject { FinancialTransaction.find_by(qbd_id: "4024", company_id: company.id) }

        specify 'loaded transaction' do
          expect(subject.amount_cents).to eq(-7079)
          expect(subject.is_credit).to be_true
        end
        it_behaves_like "transaction from qbd journal entry"
      end
    end
  end
  
  context 'When there are FinancialTransactions in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "4021", source: 'qbd_journal_entry'}
    before { engine.process batch }
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: -7079
  end
  
end
