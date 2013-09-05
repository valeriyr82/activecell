require 'spec_helper'

describe 'load_qbd_accounts' do
  include_context 'intuit extraction setup', "load_qbd_accounts"
      
  context 'When no accounts are in the database' do 
    before { engine.process batch }

    it "should associate accounts with company" do
      all = Account.all.all? { |c| c.company_id == company.id }
      all.should  be_true, "Not all accounts have correct company_id"
    end
    
    it "should create as many accounts as there are in the server response" do
      Account.count.should == 7
    end
    
    it "should create assign default type if no type was given in response" do
      acc = Account.find_by(name: 'Typeless')
      acc.type.should == "Non-Posting"
    end
    
    it "should populate all the fields" do
      acc = Account.first
      [:qbd_id, :name, :active, :type, :sub_type, :account_number, :company_id].each{ |k| acc[k].should_not be_nil }
    end
    
    context 'When parent id is in the response' do
      let(:parent) {Account.find_by(qbd_id: '140')}
      let(:child1) {Account.find_by(qbd_id: '135')} # it has AccountParentId set to 140
      let(:child2) {Account.find_by(qbd_id: '133')} # it has AccountParentId set to 140
      let(:orphan) {Account.find_by(qbd_id: '136')} # it has AccountParentId set to 999
      
      it "post process should assign the parent keys so the parent_account affiliation works" do
        child1.parent_account.should == parent
        child2.parent_account.should == parent
      end
      
      it "post process should assign the children keys so the children_accounts affiliation works" do
        parent.children_accounts.should include child1
        parent.children_accounts.should include child2
      end
      
      it "post process should ignore incorrect parent id" do
        orphan.parent_account.should be_nil
      end
    end
  end

  context 'When there are accounts in the database' do 
    let!(:account) {create(:account, company: company, qbd_id: '140', name: "Test!!")}
    before { engine.process batch }
    
    it "should update it if company_id and qbd_id are the same" do
      account.reload.name.should == "Reimbursements payable" #taken from the vcr
    end
  end
end
