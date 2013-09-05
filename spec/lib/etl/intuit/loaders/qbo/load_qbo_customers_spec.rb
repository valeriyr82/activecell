require 'spec_helper'

describe 'load_qbo_customers' do
  include_context 'quickbooks online extraction setup', 'load_qbo_customer'
      
  context 'When no customers are in the database' do 
    before { engine.process batch }
    
    it "should fill database with all customers in response" do
      Customer.count.should == 29
    end
    
    it "all customers should have correct company_id" do
      all = Customer.all.all? { |c| c.company_id == company.id }
      all.should  be_true, "Not all customers have correct company_id"
    end
  end
  
  context 'When customers records exists in the database' do 
    let!(:customer) { create(:customer, company: company, qbo_id: 245, name: "whatever") }
    let!(:id) { customer.id }
    
    before { engine.process batch }
    
    it "should update customer if company_id and qbo_id are the same" do
      customer.reload.name.should == "Analytix Solutions" #taken from the vcr
    end
  end
    
end
