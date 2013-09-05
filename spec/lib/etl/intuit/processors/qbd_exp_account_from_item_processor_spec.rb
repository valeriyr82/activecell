require 'spec_helper'

describe ETL::Processor::ExpAccountFromItemProcessor do
  shared_examples_for 'exp_account_form_item processor' do |provider_class|
    let!(:provider_module) {"ETL::#{provider_class.upcase}".constantize}
    let!(:processor_class) {"ETL::Processor::#{provider_class.capitalize}ExpAccountFromItemProcessor".constantize}
    
    describe "When :posting_type is :debit" do
      let!(:processor) {processor_class.new(nil, {:posting_type => :debit})}
      let(:row) {{"ItemId" => 1}}
    
      before do
        @exp_lu = mock, @cogs_lu = mock, @asset_lu = mock
        provider_module.should_receive(:get_product_exp_account_lookup).and_return(@exp_lu)
        provider_module.should_receive(:get_product_cogs_account_lookup).and_return(@cogs_lu)
        provider_module.should_receive(:get_product_asset_account_lookup).and_return(@asset_lu)
      end
    
      describe "When account found by the first lookup" do
      
        before do
          @exp_lu.should_receive(:transform).with(nil, 1, row).and_return(123)
          @cogs_lu.should_not_receive(:transform)
          @asset_lu.should_not_receive(:transform)
          provider_module.should_not_receive :get_default_exp_account
        end
      
        subject{processor.process(row)}
        it { should == {"ItemId" => 1, :exp_account_id => 123, :debit_account_sk => true}}
      end

      describe "When account found by the second lookup" do
        before do
          @exp_lu.should_receive(:transform)
          @cogs_lu.should_receive(:transform).with(nil, 1, row).and_return(234)
          @asset_lu.should_not_receive(:transform)
          provider_module.should_not_receive :get_default_exp_account
        end
      
        subject{processor.process(row)}
        it { should == {"ItemId" => 1, :exp_account_id => 234, :debit_account_sk => true}}
      end
 
      describe "When account found by the fourth lookup" do
        before do
          @exp_lu.should_receive(:transform)
          @cogs_lu.should_receive(:transform)
          @asset_lu.should_receive(:transform)
          provider_module.should_receive(:get_default_exp_account).and_return(546)
        end
      
        subject{processor.process(row)}
        it { should == {"ItemId" => 1, :exp_account_id => 546, :debit_account_sk => true}}
      end
    
      describe "When account found by the third lookup" do
        before do
          @exp_lu.should_receive(:transform)
          @cogs_lu.should_receive(:transform)
          @asset_lu.should_receive(:transform).with(nil, 1, row).and_return(345)
          provider_module.should_not_receive :get_default_exp_account
        end
      
        subject{processor.process(row)}
        it { should == {"ItemId" => 1, :exp_account_id => 345, :debit_account_sk => true}}
      end
    end
  
    describe "When AccountId given" do
      let!(:processor) {processor_class.new(nil, {:posting_type => :debit})}
      let(:row) {{"AccountId" => 789}}
      
      before do
        provider_module.should_not_receive(:get_product_exp_account_lookup)
        provider_module.should_not_receive(:get_product_cogs_account_lookup)
        provider_module.should_not_receive(:get_product_asset_account_lookup)
      end
      
      subject{processor.process(row)}
      it { should == {"AccountId" => 789, :exp_account_id => 789}}
    end
  
    describe "When :posting_type is :credit" do
      let!(:processor) {processor_class.new(nil, {:posting_type => :credit})}
      let(:row) {{"ItemId" => 1}}
    
      before do
        @exp_lu = mock
        provider_module.should_receive(:get_product_exp_account_lookup).and_return(@exp_lu)
        @exp_lu.should_receive(:transform).with(nil, 1, row).and_return(123)
        provider_module.should_not_receive :get_default_exp_account
      end
    
      subject{processor.process(row)}
      it {subject[:credit_account_sk] == true}
      it {subject.should_not include :debit_account_sk}
    end
  end
  
  describe 'for QBO' do
    it_behaves_like 'exp_account_form_item processor', "QBO"
  end
  
  describe 'for QBD' do
    it_behaves_like 'exp_account_form_item processor', "QBD"
  end
  
  
end
