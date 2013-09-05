require 'spec_helper'

describe 'load_qbo_employees' do
  include_context 'quickbooks online extraction setup', 'load_qbo_employee'
      
  context 'When no employees are in the database' do 
    before { engine.process batch }

    it "should associate employees with company" do
      all = Employee.all.all? { |c| c.company_id == company.id }
      all.should  be_true, "Not all employees have correct company_id"
    end
    
    it "should fill database with employees from response" do
      Employee.count.should == 6
    end
    
    it "should populate all the fields for all the employees" do
      Employee.all.each do |e|
        [:qbo_id, :name, :company_id].each{ |k| e[k].should_not be_nil, "Failed for #{k}\n" + e.inspect}
      end
    end
    
    context 'When checking Edward Campion record' do
      subject { Employee.find_by(qbo_id: "264")}

      specify 'loaded employee' do
        expect(subject.active).to be_nil
        expect(subject.company_id).to eq(company.id)
        expect(subject.name).to eq("Edward Campion")
        expect(subject.hire_date).to be_nil
        expect(subject.end_date).to be_nil
      end
    end
  end

  context 'When some employees already in the db' do
    let!(:employee1) { create(:employee, qbo_id: 264, company: company, name: "Marilyn") }
    let!(:employee2) { create(:employee, qbo_id: 9908, company: company, name: "Johnny") }
    
    before { engine.process batch }
    
    it "should update an existing employee" do
      employee1.reload.name.should == "Edward Campion"
    end
    
    it "should delete existing employees not mentioned in the received data" do
      lambda{ employee2.reload.name }.should raise_error Mongoid::Errors::DocumentNotFound
    end
  end
    
end
