require 'spec_helper'

describe ETL::Processor::QbdRevAccountFromItemProcessor do
  
  describe "When :posting_type is :debit" do
    let!(:processor) {ETL::Processor::QbdRevAccountFromItemProcessor.new(nil, {:posting_type => :debit})}
    let(:row) {{"ItemId" => 1, "RevAccountId" => 'thisShouldBeGone'}}
    
    before do
      @acc_lu = mock
      ETL::QBD.should_receive(:get_product_inc_account_lookup).and_return(@acc_lu)
    end
    
    describe "When account found by the first lookup" do
      before do
        @acc_lu.should_receive(:transform).with(nil, 1, row).and_return(123)
        ETL::QBD.should_not_receive :get_default_rev_account
      end
      
      subject{processor.process(row)}
      it { should == {"ItemId" => 1, :rev_account_id => 123, :debit_account_sk => true}}
    end
    
    describe "When account found by the second lookup" do
      before do
        @acc_lu.should_receive(:transform).with(nil, 1, row)
        ETL::QBD.should_receive(:get_default_rev_account).and_return(234)
      end

      subject{processor.process(row)}
      it { should == {"ItemId" => 1, :rev_account_id => 234, :debit_account_sk => true}}
    end
  end
  
  describe "When :posting_type is :debit" do
    let!(:processor) {ETL::Processor::QbdRevAccountFromItemProcessor.new(nil, {:posting_type => :credit})}
    let(:row) {{"ItemId" => 1, "RevAccountId" => 'thisShouldBeGone'}}
    
    before do
      @acc_lu = mock
      ETL::QBD.should_receive(:get_product_inc_account_lookup).and_return(@acc_lu)
    end
    
    describe "When account found by the first lookup" do
      before do
        @acc_lu.should_receive(:transform).with(nil, 1, row).and_return(111)
        ETL::QBD.should_not_receive :get_default_rev_account
      end
      
      subject{processor.process(row)}
      it { should == {"ItemId" => 1, :rev_account_id => 111, :credit_account_sk => true}}
    end
  end
  
end
