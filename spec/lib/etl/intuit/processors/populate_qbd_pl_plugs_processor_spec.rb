require 'spec_helper'

describe ETL::Processor::PopulateQbdPlPlugsProcessor do
  include_context 'intuit extraction setup'
  let!(:account) {create(:account, :type => 'Revenue', :current_balance => 0, :company => company, :qbd_id => '9999test')}

  describe 'When populating with populate_qbd_pl_plugs.ebf' do
    let!(:batch) do
      batch_file = Rails.root.to_s + "/spec/fixtures/etl/qbd/populate_qbd_pl_plugs.ebf"
      ETL::Batch::Batch.resolve(batch_file, nil, 
        {company_id: company.id, batch_id: execution_batch.id, authentication: batch_auth_hash})
    end
    
    before do
      first_period = Time.now.beginning_of_month - 3.months
      4.times do |time|
        Period.find_or_create_by(first_day: first_period + time.months)
      end
    end
    
    
    describe 'when there are no transactions but report has income for $150'  do 
      # bottom_up_numbers is 0
      # report for june is income: $100
      # report for july is income: $50
      # it should create 2 plugs one for -10000 (cents) and 2nd for -5000
      before do
        VCR.use_cassette('qbd/qbd_pl_plugs_test_extractions', match_requests_on: [:method, :uri]) do
          engine.process batch
        end
      end
      
      subject {account.financial_transactions}
      
      its(:size) { should == 2 }
      
      it "should have correct transaction_date date" do
        subject[0].transaction_date.should == Date.parse("01-06-2012").end_of_month
      end
      
      it "should have one for -10000" do
        subject[0].amount_cents.should == -10000
      end
      
      it "should have correct transaction_date date" do
        subject[1].transaction_date.should == Date.parse("01-07-2012").end_of_month
      end
      
      it "should have one for -5000" do
        subject[1].amount_cents.should == -5000
      end
      
      it "should have plugs associated with correct account and company" do
        subject.each do |ft|
          ft.company_id.should == company.id
          ft.account_id.should == account.id
        end
      end
    end
    
    describe "when transactions are equal to the reports" do
      let!(:ft1) { create(:financial_transaction, company: company,
          transaction_date: "5-06-2012", account: account, amount_cents: -5000) }
      let!(:ft2) { create(:financial_transaction, company: company,
          transaction_date: "15-06-2012", account: account, amount_cents: -5000) }
      let!(:ft3) { create(:financial_transaction, company: company,
          transaction_date: "05-07-2012", account: account, amount_cents: -5000) }
      
      # bottom_up_numbers total is -$150
      # report for june is income: $100
      # report for july is income: $50
      # it should not create any plugs
      before do
        FinancialTransaction.should_not_receive(:create_plug!)
        
        VCR.use_cassette('qbd/qbd_pl_plugs_test_extractions', match_requests_on: [:method, :uri]) do
          engine.process batch
        end
      end
      
      it do
        account.financial_transactions.where(:source => 'Profitably:Plug').size.should == 0
      end
    end
    
    
    describe "when account has 2 transactions that add up to $3000 and account isn't in report" do
      let!(:dc_account) { create(:account, :type => 'Revenue',
          :current_balance => 0, :company => company, :qbd_id => '8888test') }

      let!(:ft1) { create(:financial_transaction, company: company,
          transaction_date: "05-06-2012", account: dc_account, amount_cents: 10000) }
      let!(:ft2) { create(:financial_transaction, company: company,
          transaction_date: "25-06-2012", account: dc_account, amount_cents: 20000) }
      
      before do
        VCR.use_cassette('qbd/qbd_pl_plugs_test_extractions', match_requests_on: [:method, :uri]) do
          engine.process batch
        end
      end
      
      subject {dc_account.financial_transactions.where(:source => 'Profitably:Plug').first}
      
      it 'should have 1 plug created' do
        dc_account.financial_transactions.where(:source => 'Profitably:Plug').size.should == 1
      end
      
      its(:amount_cents) { should == -30000 }
    end
    
    describe "when transactions add up to a smaller sum than reports says"  do
      let!(:ft1) { create(:financial_transaction, company: company,
          transaction_date: "5-06-2012", account: account, amount_cents: 300000) }
      let!(:ft2) { create(:financial_transaction, company: company,
          transaction_date: "15-06-2012", account: account, amount_cents: 1500000) }
      
      before do
        VCR.use_cassette('qbd/qbd_pl_plugs_test_extractions_bigger_report', match_requests_on: [:method, :uri]) do
          engine.process batch
        end
      end
      
      subject {account.financial_transactions.where(:source => 'Profitably:Plug').first}
      
      it 'should create plug for $2000' do
        subject.amount_cents.should == 200000
      end
    end
  end
end
