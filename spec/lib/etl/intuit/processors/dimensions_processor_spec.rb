require 'spec_helper'

describe ETL::Processor::DimensionsProcessor do 
  shared_context "objects and stubs for qbo/qbd dimensions processor" do |provider_class|
    let!(:company) { create(:company) }
    let(:row) {{
        "CustomerId" => 1, "EmployeeId" => 1, "VendorId" => 1, "ItemId" => 1}}
    
    before do
      @customer_lu = mock, @employee_lu = mock, @vendor_lu = mock, @product_lu = mock
      namespace = "ETL::#{provider_class}".constantize
      namespace.should_receive(:get_customer_id_lookup).and_return(@customer_lu)
      namespace.should_receive(:get_employee_id_lookup).and_return(@employee_lu)
      namespace.should_receive(:get_vendor_id_lookup).and_return(@vendor_lu)
      namespace.should_receive(:get_product_id_lookup).and_return(@product_lu)
    end
  end
  
  shared_examples_for 'dimensions processor' do
    describe 'When no "EntityType" passed' do
      before do
        @customer_lu.should_receive(:transform).with('customer', 1, row).and_return(1)
        @employee_lu.should_receive(:transform).with('employee', 1, row).and_return(1)
        @vendor_lu.should_receive(:transform).with('vendor', 1, row).and_return(1)
        @product_lu.should_receive(:transform).with('product', 1, row).and_return(1)
      end
    
      subject{processor.process(row)}
      it { should_not be_nil }
      it { should == {:customer_id => 1, :employee_id => 1, :product_id => 1, :vendor_id => 1} }
    end
  
    describe 'When "EntityType" and "EntityId" set to "Customer"' do
      let(:row) {{
          "EmployeeId" => 1, "VendorId" => 1, "ItemId" => 1,
          "EntityType" => 'Customer', "EntityId" => 2
        }}
    
      before do
        @customer_lu.should_receive(:transform).with('customer', 2, row).and_return(2)
        @employee_lu.should_receive(:transform).with('employee', 1, row).and_return(1)
        @vendor_lu.should_receive(:transform).with('vendor', 1, row).and_return(1)
        @product_lu.should_receive(:transform).with('product', 1, row).and_return(1)
      end
    
      subject{processor.process(row)}
      it { should_not be_nil }
      it { should == {"EntityType" => 'Customer', "EntityId" => 2, :customer_id => 2, :employee_id => 1, :product_id => 1, :vendor_id => 1} }
    end
  
    describe 'When "EntityType" and "EntityId" set to "Vendor"' do
      let(:row) {{
          "EmployeeId" => 1, "CustomerId" => 1, "ItemId" => 1,
          "EntityType" => 'Vendor', "EntityId" => 2
        }}
    
      before do
        @customer_lu.should_receive(:transform).with('customer', 1, row).and_return(1)
        @employee_lu.should_receive(:transform).with('employee', 1, row).and_return(1)
        @vendor_lu.should_receive(:transform).with('vendor', 2, row).and_return(2)
        @product_lu.should_receive(:transform).with('product', 1, row).and_return(1)
      end
    
      subject{processor.process(row)}
      it { should_not be_nil }
      it { should == {"EntityType" => 'Vendor', "EntityId" => 2, :customer_id => 1, :employee_id => 1, :product_id => 1, :vendor_id => 2} }
    end
  
    describe 'When "EntityType" and "EntityId" set to "Employee"' do
      let(:row) {{
          "CustomerId" => 1, "VendorId" => 1, "ItemId" => 1,
          "EntityType" => 'Employee', "EntityId" => 2
        }}
    
      before do
        @customer_lu.should_receive(:transform).with('customer', 1, row).and_return(1)
        @employee_lu.should_receive(:transform).with('employee', 2, row).and_return(2)
        @vendor_lu.should_receive(:transform).with('vendor', 1, row).and_return(1)
        @product_lu.should_receive(:transform).with('product', 1, row).and_return(1)
      end
    
      subject{processor.process(row)}
      it { should_not be_nil }
      it { should == {"EntityType" => 'Employee', "EntityId" => 2, :customer_id => 1, :employee_id => 2, :product_id => 1, :vendor_id => 1} }
    end
  
  
  
    describe 'When "EntityType" and "EntityId" are invalid' do
      let(:row) {{
          "EmployeeId" => 1, "CustomerId" => 1, "VendorId" => 1, "ItemId" => 1,
          "EntityType" => 'Ghosts!', "EntityId" => 2
        }}
    
      before do
        @customer_lu.should_receive(:transform).with('customer', 1, row).and_return(1)
        @employee_lu.should_receive(:transform).with('employee', 1, row).and_return(1)
        @vendor_lu.should_receive(:transform).with('vendor', 1, row).and_return(1)
        @product_lu.should_receive(:transform).with('product', 1, row).and_return(1)
      end
    
      subject{processor.process(row)}
      it { should_not be_nil }
      it { should == {"EntityType" => 'Ghosts!', "EntityId" => 2, :customer_id => 1, :employee_id => 1, :product_id => 1, :vendor_id => 1} }
    end
  end
  
  describe "for QBO" do
    include_context "objects and stubs for qbo/qbd dimensions processor", "QBO"
    let!(:processor) {ETL::Processor::QboDimensionsProcessor.new(nil, {})}
    it_behaves_like 'dimensions processor'
  end
  
  describe "for QBD" do
    include_context "objects and stubs for qbo/qbd dimensions processor", "QBO"
    let!(:processor) {ETL::Processor::QboDimensionsProcessor.new(nil, {})}
    it_behaves_like 'dimensions processor'
  end
  
end
