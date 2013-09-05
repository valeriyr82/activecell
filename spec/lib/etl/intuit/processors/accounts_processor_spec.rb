require 'spec_helper'

describe ETL::Processor::AccountsProcessor do
  shared_context "objects and stubs for qbo/qbd accounts processor" do |provider|
    let!(:company) { create(:company) }
    let!(:debit_account) { create(:account, company: company) }
    let!(:credit_account) { create(:account, company: company) }

    let!(:processor) {"ETL::Processor::#{provider}AccountsProcessor".constantize.new(nil, {
          :credit_account => :credit_account, 
          :debit_account => :debit_account })}
  end
  
  shared_examples_for 'accounts processor' do |provider_class|
    describe 'When all parameters given' do
      let!(:row) {{:credit_account => 'A', :debit_account => 'B', "Amount" => 1000}}
      before do
        # need to stub the fk lookup transform or create an account so it returns it
        lookup = mock
        lookup.should_receive(:transform).with(nil, row[:credit_account], row).and_return(credit_account.id)
        lookup.should_receive(:transform).with(nil, row[:debit_account], row).and_return(debit_account.id)
        "ETL::#{provider_class}".constantize.should_receive(:get_account_id_lookup).and_return(lookup)
      end

      subject{ processor.process(row) }

      it do
        expected_result = 
          [{:credit_account => "A", :debit_account => "B", :amount => -100000, :is_credit => 1, :account_id => credit_account.id}, 
          {:credit_account => "A", :debit_account => "B", :amount => 100000, :is_credit => 0, :account_id => debit_account.id}]
        should == expected_result
      end
    end

    describe "When :debit_account_sk, :credit_account_sk given" do
      let!(:row) {{:credit_account => credit_account.id, :debit_account => debit_account.id, 
          "Amount" => 2000, :debit_account_sk => true, :credit_account_sk => true}}

      before do
        # need to stub the fk lookup transform or create an account so it returns it
        lookup = mock
        lookup.should_not_receive(:transform).with(nil, row[:credit_account], row)
        lookup.should_not_receive(:transform).with(nil, row[:debit_account], row)
        "ETL::#{provider_class}".constantize.should_receive(:get_account_id_lookup).and_return(lookup)
      end

      subject{ processor.process(row) }

      it do
        expected_result = 
          [{:credit_account => credit_account.id, :debit_account => debit_account.id, :debit_account_sk => true, :credit_account_sk => true, :amount => -200000, :is_credit => 1, :account_id => credit_account.id}, 
          {:credit_account => credit_account.id, :debit_account => debit_account.id, :debit_account_sk => true, :credit_account_sk => true, :amount => 200000, :is_credit => 0, :account_id => debit_account.id}]
        should == expected_result
      end

    end
  end
  
  describe 'for QBO' do
    include_context "objects and stubs for qbo/qbd accounts processor", "Qbo"
    it_behaves_like 'accounts processor', "QBO"
  end
  
  describe 'for QBD' do
    include_context "objects and stubs for qbo/qbd accounts processor", "Qbd"
    it_behaves_like 'accounts processor', "QBD"
  end
  
end
