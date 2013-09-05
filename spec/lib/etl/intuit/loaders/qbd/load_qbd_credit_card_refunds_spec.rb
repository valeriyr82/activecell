require 'spec_helper'

describe 'load_qbd_credit_card_refunds' do
  include_context 'intuit extraction setup', 'load_qbd_credit_card_refunds'
  include_context 'stubbed processors for intuit'
  
  context 'When there are no FinancialTransactions in the db yet' do
    before { engine.process batch }

    it "should fill database with FinancialTransactions from response" do
      FinancialTransaction.count.should == 8
    end
    
    it "should create 3x2 transactions for qbd_id == '8204'" do
      FinancialTransaction.all.to_a.map(&:qbd_id).uniq.each do |qdb_id|
        transactions = FinancialTransaction.where(qbd_id: "CreditMemo: 8204")
        transactions.count.should == 6
        transactions.where(is_credit: true).size.should == 3
        transactions.where(is_credit: false).size.should == 3
      end
    end
    
    it "should create 2 transactions for qbd_id == '8404'" do
      transactions = FinancialTransaction.where(qbd_id: "Deposit: 8404")
      transactions.count.should == 2
    end
    
    context 'When looking at a single created transaction' do
      shared_examples_for "credit memo" do
        specify 'loaded transaction' do
          expect(subject.source).to eq('qbd_credit_card_refund')
          expect(subject.transaction_date).to eq(Date.parse('2012-01-31'))
          expect(subject.vendor_id).to eq(vendor.id)
          expect(subject.period_id).to eq(Period.first.id)
          expect(subject.account_id).to eq(account.id)
          expect(subject.product_id).to eq(product.id)
          expect(subject.customer_id).to eq(customer.id)
          expect(subject.status).to be_nil
        end
      end
      
      describe 'for a charge record' do
        subject { FinancialTransaction.find_by(qbd_id: "Deposit: 8404", company_id: company.id, is_credit: true) }

        specify 'loaded transaction' do
          expect(subject.amount_cents).to eq(13065)
          expect(subject.is_credit).to be_true
        end

        it_behaves_like "credit memo"
      end
    
      describe 'for a gain record' do
        subject { FinancialTransaction.find_by(qbd_id: "Deposit: 8404", company_id: company.id, is_credit: false) }

        specify 'loaded transaction' do
          expect(subject.amount_cents).to eq(-13065)
          expect(subject.is_credit).to be_false
        end

        it_behaves_like "credit memo"
      end
    end
  end
  
  context 'When there are FinancialTransactions in the db' do
    include_context 'financial transactions for qbd_load jobs', {qbd_id: "Deposit: 8404", source: 'qbd_credit_card_refund'}
    before { engine.process batch }
    
    it_behaves_like 'like it has :check_for_deletes set to true', amount_cents: 13065
  end
end
