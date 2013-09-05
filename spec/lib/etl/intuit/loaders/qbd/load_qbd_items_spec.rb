require 'spec_helper'

describe 'load_qbd_items' do
  include_context 'intuit extraction setup', 'load_qbd_items'
      
  let!(:account) {create(:account, company: company)}
  
  before do
    # mock the account id lookup which is called in the after_read directive
    lookup = mock
    lookup.stub(:transform).and_return(account.id)
    ETL::QBD.should_receive(:get_account_id_lookup).and_return(lookup)
  end

  context 'When there are no items in the db yet' do
    before { engine.process batch }
    
    it "should associate products(items) with company" do
      all = Product.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all employees have correct company_id"
    end
  
    it "should fill database with items from response" do
      Product.count.should == 9
    end
  
    context 'When comparing a single record' do
      subject { Product.find_by(qbd_id: '16') }

      specify 'loaded product' do
        expect(subject.name).to eq('Monitor (expensed)')
        expect(subject.description).to eq('Just a monitor')
        expect(subject.qbd_type).to eq("Product")
        expect(subject.income_account_id).to eq(account.id)
        expect(subject.expense_account_id).to eq(account.id)
        expect(subject.asset_account_id).to be_nil
        expect(subject.cogs_account_id).to be_nil
      end
    end
  end
  
  describe "When there are some items in the db" do
    let!(:product) {create(:product, company: company, qbd_id: "16", name: 'Blobitor')}
    let!(:product_to_die) {create(:product, company: company, qbd_id: '237')}
    
    before { engine.process batch }
    
    it 'should update the one with same qbd_id and company' do
      product.reload.name.should == "Monitor (expensed)"
    end
    
    it "should remove all of items not mentioned in the response" do
      lambda{product_to_die.reload.name}.should raise_error Mongoid::Errors::DocumentNotFound
    end
  end
end
