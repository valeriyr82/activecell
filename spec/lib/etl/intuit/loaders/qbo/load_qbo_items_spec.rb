require 'spec_helper'

describe 'load_qbo_items' do
  include_context 'quickbooks online extraction setup', 'load_qbo_item'
  include_context 'stubbed processors for qbo'
      
  let!(:account) { create(:account, company: company) }
  
  before do
    # mock the account id lookup which is called in the after_read directive
    lookup = mock
    lookup.stub(:transform).and_return(account.id)
    ETL::QBO.should_receive(:get_account_id_lookup).and_return(lookup)
  end

  context 'When there are no items in the db yet' do
    before { engine.process batch }

    it "should associate products(items) with company" do
      all = Product.all.all? { |c| c.company_id == company.id }
      all.should be_true, "Not all products have correct company_id"
    end
  
    it "should fill database with items from response" do
      Product.count.should == 17
    end
  
    context 'When comparing a single record' do
      subject { Product.find_by(qbo_id: '2') }

      specify 'loaded product' do
        expect(subject.name).to eq('Basecamp Personal')
        expect(subject.income_account_id).to eq(account.id)
        expect(subject.cogs_account_id).to be_nil
        expect(subject.expense_account_id).to be_nil
        expect(subject.asset_account_id).to be_nil
      end
    end
  end
  
  describe "When there are some items in the db" do
    let!(:product) { create(:product, company: company, qbo_id: "2", name: 'Blobitor') }
    let!(:product_to_die) { create(:product, company: company, qbo_id: '237') }
    let!(:qbd_product_to_stay) { create(:product, company: company, qbd_id: '237') }
    
    before { engine.process batch }
    
    it 'should update the one with same qbd_id and company' do
      product.reload.name.should == "Basecamp Personal"
    end
    
    it "should remove all of items not mentioned in the response" do
      lambda{ product_to_die.reload.name }.should raise_error Mongoid::Errors::DocumentNotFound
    end
    
    it "should not remove qbd items not mentioned in the response" do
      qbd_product_to_stay.reload.should_not be_nil
    end
  end
end
