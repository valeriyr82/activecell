require 'spec_helper'

describe 'load_qbo_bill_payments' do
  include_context 'quickbooks online extraction setup', 'load_qbo_bill_payment'

  context 'with stubbed processors' do
    include_context 'stubbed processors for qbo'
    
    before { engine.process batch }
    
    it "should create unique qbo_id for each pair of created financial transactions" do
      ids = FinancialTransaction.all.map &:qbo_id
      ids.uniq.size.should == FinancialTransaction.count
    end
  end

  context 'without stubbed processors' do
    let!(:period) { Period.create(first_day: Date.new(2012,1,1).to_time) }
    # need to pass :id because facotries would create with different ids while 
    # resolver caches the ids of found records which leads to errors v. difficult to debug
    let!(:vendor) { create(:vendor, company: company, qbo_id: '123', id: '123') }
    let!(:bank_account) { create(:account, company: company, qbo_id: '94', id: '94') }
    let!(:ap_account) { create(:account, company: company, sub_type: "Accounts Payable", id: '34', qbo_id: "34") }
    
    before do
      # stub for the qbo_dates_processor
      ETL::QBO.stub(:get_period_id_lookup).and_return(stub(transform: period.id))
      engine.process batch
    end
    
    describe 'When looking at a single created transaction' do
      # all the ids taken from the last bill in load_qbo_bill_payments.yml
      subject { FinancialTransaction.find_by(qbo_id: "269", company_id: company.id, is_credit: false) }

      specify do
        expect(subject.source).to eq('qbo_bill_payment')
        expect(subject.amount_cents).to eq(270000)
        expect(subject.transaction_date).to eq(Date.parse("2010-11-05-07:00"))
        expect(subject.vendor_id).to eq(vendor.id)
        expect(subject.period_id).to eq(period.id)
        expect(subject.account_id).to eq(ap_account.id)
        expect(subject.product_id).to be_nil
        expect(subject.customer_id).to be_nil
        expect(subject.status).to be_nil
      end
    end
    
    it "should associate FinancialTransactions with company" do
      all = FinancialTransaction.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all FinancialTransactions have correct company_id"
    end
    
    it "should fill database with FinancialTransactions from response" do
      FinancialTransaction.count.should == 2
    end
    
    it "should create two transactions per each entry" do
      FinancialTransaction.all.to_a.map(&:qbo_id).uniq.each do |qbo_id|
        transactions = FinancialTransaction.where(qbo_id: qbo_id)
        transactions.count.should == 2
        transactions.select{ |t| t.is_credit == true }.should_not be_nil
        transactions.select{ |t| t.is_credit == false }.should_not be_nil
      end
    end
  end
  
end
