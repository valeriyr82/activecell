require 'spec_helper'

describe 'load_qbd_employees' do
  include_context 'intuit extraction setup', 'load_qbd_employees'
      
  context 'When no employees are in the database' do 
    before { engine.process batch }

    it "should associate employees with company" do
      all = Employee.all.all? { |c| c.company_id == company.id }
      all.should  be_true, "Not all employees have correct company_id"
    end
    
    it "should fill database with employees from response" do
      Employee.count.should == 6
    end
    
    it "should populate all the fields" do
      Employee.all.each do |e|
        [:qbd_id, :name, :active, :company_id].each{|k| e[k].should_not be_nil, "Failed for #{k}\n" + e.inspect}
      end
    end
    
    context 'When checking Edward Campion record' do
      subject { Employee.find_by(qbd_id: "268") }

      specify 'loaded employee' do
        expect(subject.active).to eq("INACTIVE")
        expect(subject.company_id).to eq(company.id)
        expect(subject.name).to eq("Edward Campion")
        expect(subject.hire_date).to eq(Date.parse('2012-02-09'))
        expect(subject.end_date).to eq(Date.parse('2012-03-09'))
      end
    end
  end

  context 'When some employees already in the db' do
    let!(:employee1) {create(:employee, qbd_id: 98, company: company, name: "Marilyn")}
    let!(:employee2) {create(:employee, qbd_id: 998, company: company, name: "Johnny")}
    
    before { engine.process batch }
    
    it "should update an existing employee" do
      employee1.reload.name.should == "Graham Siener"
    end
    
    it "should delete existing employees not mentioned in the received data" do
      lambda{employee2.reload.name}.should raise_error Mongoid::Errors::DocumentNotFound
    end
  end
  
end
