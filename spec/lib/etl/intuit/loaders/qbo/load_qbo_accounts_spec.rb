require 'spec_helper'

describe 'load_accounts' do
  include_context 'quickbooks online extraction setup', 'load_qbo_account'
  
  context 'When there are no Accounts in the db yet' do
    before { engine.process batch }

    it "should have same amount of accounts as in response" do
      Account.count.should == 99
    end
    
    it "should associate accounts with company" do
      all = Account.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all accounts have correct company_id"
    end
    
    it "should populate all the fields" do
      acc = Account.first
      [:qbo_id, :name, :type, :sub_type, :account_number, :company_id].each{ |k| acc[k].should_not be_nil }
    end

    context 'When parent id is in the response' do
      let(:parent) { Account.find_by(qbo_id: '140') }
      let(:child1) { Account.find_by(qbo_id: '155') } # it has AccountParentId set to 140
      let(:child2) { Account.find_by(qbo_id: '82') } # it has AccountParentId set to 140
      let(:orphan) { Account.find_by(qbo_id: '139') } # it has AccountParentId set to 1077
      
      it "post process should assign the parent keys so the parent_account relation works" do
        child1.parent_account.should == parent
        child2.parent_account.should == parent
      end
      
      it "post process should assign the children keys so the children_accounts relation works" do
        parent.children_accounts.should include child1
        parent.children_accounts.should include child2
      end
      
      it "post process should ignore incorrect parent id" do
        orphan.parent_account.should be_nil
      end
    end
    
    context 'Type' do
      it "should be set correctly" do
        account = Account.find_by(qbo_id: '131')
        account.type.should == "Liability"
        account = Account.find_by(qbo_id: '155')
        account.type.should == "Expense"
      end
      
      it "should never be nil" do
        Account.all.none?{ |a| a.type.nil? }.should be_true
      end
    end
  end

  context 'When there are accounts in the database' do 
    let!(:account) { create(:account, company: company, qbo_id: '140', name: "Test!!") }
    
    before { engine.process batch }
    
    it "should update it if company_id and qbd_id are the same" do
      account.reload.name.should == "Deferred Income (Annual Plans)" #taken from the vcr
    end
  end  
  
end
