require 'spec_helper'

describe 'load_qbd_vendors' do
  include_context 'intuit extraction setup', "load_qbd_vendors"
  
  context 'When there are no vendors in the db yet' do
    before { engine.process batch }
    
    it "should associate vendors with company" do
      all = Vendor.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all vendors have correct company_id"
    end
    
    it "should fill database with vendors from response" do
      Vendor.count.should == 5
    end
    
    context 'When checking a single record' do
      subject { Vendor.find_by(qbd_id: "307", company_id: company.id) }

      specify 'loaded vendor' do
        expect(subject.active).to eq('true')
        expect(subject.name).to eq('Mutually Human')
      end
    end
  end
  
  context 'When some vendors already in the db' do
    let!(:vendor_with_same_qbd_company) {create(:vendor, qbd_id: 307, company: company, name: "Mutually Robot")}
    let!(:not_mentioned_vendor) {create(:vendor, qbd_id: 998, company: company)}
  
    before { engine.process batch }
    
    it "should update an existing vendor" do
      vendor_with_same_qbd_company.reload.name.should == "Mutually Human"
    end
    
    it "should delete existing vendors not mentioned in the received data" do
      lambda{not_mentioned_vendor.reload.name}.should raise_error Mongoid::Errors::DocumentNotFound
    end
  end
end
