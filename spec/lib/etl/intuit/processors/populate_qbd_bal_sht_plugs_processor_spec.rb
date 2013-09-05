require 'spec_helper'

describe ETL::Processor::PopulateQbdBalShtPlugsProcessor do
  include_context 'intuit extraction setup'
  let!(:account_1) { create(:account, :qbd_id => "46", :company => company) }
  let!(:account_2) { create(:account, :qbd_id => "136", :company => company) }

  describe 'When populating database with populate_qbd_account_balances.ctl' do
    let!(:batch) do
      batch_file = Rails.root.to_s + "/spec/fixtures/etl/qbd/populate_qbd_bal_sht_plugs.ebf"

      ETL::Batch::Batch.resolve(batch_file, nil, 
        {company_id: company.id, batch_id: execution_batch.id, authentication: batch_auth_hash})
    end
    
    before do
      first_period = Time.now.beginning_of_month - 3.months
      4.times do |time|
        Period.find_or_create_by(first_day: first_period + time.months)
      end
    end
    
    
    describe "When an account with a non-zero balance doesn't appear in the balance sheet reports" do
      let!(:account_not_mentioned) { create(:account, :qbd_id => "oh_well", :company => company, :current_balance => 100000) }
      let!(:ft1) { create(:financial_transaction, company: company,
          transaction_date: "05-06-2012", account: account_not_mentioned, amount_cents: 100_000_00) }
      let!(:ft2) { create(:financial_transaction, company: company,
          transaction_date: "10-06-2012", account: account_not_mentioned, amount_cents: 99_999_99) }
      
      
      it "should create a plug for it's entire balance" do
        VCR.use_cassette('qbd/qbd_bal_sht_extractions', match_requests_on: [:method, :uri]) do
          engine.process batch
        end
        
        plug = account_not_mentioned.financial_transactions.where(:source => 'Profitably:Plug').first
        plug.amount_cents.should == -199_999_99
      end
      
    end
    
    describe "When an accounts has no transactions there are some in the balance sheet" do
      # from report (summed qbd_bal_sht_extractions.yml) we have:
      # june -> {"46"=>6249, "136"=>4167}
      # july -> {"136"=>4163}
      
      before do
        VCR.use_cassette('qbd/qbd_bal_sht_extractions', match_requests_on: [:method, :uri]) do
          engine.process batch
        end
      end
      
      it 'should create 3 plugs in total' do
        FinancialTransaction.where(:source => 'Profitably:Plug').count.should == 3
      end
      
      it 'should have plug for account 1' do
        account_1.financial_transactions.first.amount_cents.should == 6249
      end
      
      it 'should have plug for june for account 2' do
        plug = account_2.financial_transactions.first
        plug.amount_cents.should == 4167
        plug.transaction_date.should == Date.parse("01-06-2012").end_of_month
      end
      
      it 'should have plug for july for account 2' do
        plug = account_2.financial_transactions.second
        plug.amount_cents.should == 4163
        plug.transaction_date.should == Date.parse("01-07-2012").end_of_month
      end
    end
    
    describe "When an account has bigger amount in the balance sheet" do
      let!(:ft1) { create(:financial_transaction, company: company,
          transaction_date: "05-06-2012", account: account_1, amount_cents: 100_00) }
      
      before do
        VCR.use_cassette('qbd/qbd_bal_sht_extractions', match_requests_on: [:method, :uri]) do
          engine.process batch
        end
      end
      
      it 'should create a plug with negative amount for this month' do
        # it should be -3751  as report says 6249 and we have 10000 in account transaction
        account_1.financial_transactions.where(:source => 'Profitably:Plug').first.amount_cents == -3751
      end
    end
    
    
    describe 'When transactions amounts are equal to the ones in report' do
      # from report (summed qbd_bal_sht_extractions.yml) we have:
      # june -> {"46"=>6249, "136"=>4167}
      # july -> {"136"=>4163}
      let!(:a1ft1) { create(:financial_transaction, company: company,
          transaction_date: "05-06-2012", account: account_1, amount_cents: 6000) }
      let!(:a1ft2) { create(:financial_transaction, company: company,
          transaction_date: "25-06-2012", account: account_1, amount_cents: 249) }
      
      let!(:a2ft1) { create(:financial_transaction, company: company,
          transaction_date: "01-06-2012", account: account_2, amount_cents: 4100) }
      let!(:a2ft2) { create(:financial_transaction, company: company,
          transaction_date: "20-06-2012", account: account_2, amount_cents: 67) }
      let!(:a2ft3) { create(:financial_transaction, company: company,
          transaction_date: "30-07-2012", account: account_2, amount_cents: 4163) }
      
      
      it "should not create any plug" do
        FinancialTransaction.should_not_receive(:create_plug!)
        VCR.use_cassette('qbd/qbd_bal_sht_extractions', match_requests_on: [:method, :uri]) do
          engine.process batch
        end
      end
    end
    
  end
end
