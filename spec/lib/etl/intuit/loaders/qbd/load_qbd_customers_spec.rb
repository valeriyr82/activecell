require 'spec_helper'

describe 'load_qbd_customers' do
  include_context 'intuit extraction setup', 'load_qbd_customers'
      
  context 'When no customers are in the database' do 
    before { engine.process batch }
    
    it "should fill database with all customers in response" do
      Customer.count.should == 3
    end
    
    it "all customers should have correct company_id" do
      all = Customer.all.all? { |c| c.company_id == company.id }
      all.should  be_true, "Not all customers have correct company_id"
    end
  end
  
  context 'When customers records exists in the database' do 
    let!(:customer) {create(:customer, company: company, qbd_id: 306, name: "remove me")}
    let!(:id) {customer.id}
    
    before { engine.process batch }
    
    it "should update customer if company_id and qbd_id are the same" do
      customer.reload.name.should == "Unleashed Testing" #taken from the vcr
    end
  end
end
