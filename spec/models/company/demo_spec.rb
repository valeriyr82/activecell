require 'spec_helper'

describe Company::Demo do
  let(:company) { create(:company) }
  subject { company }

  describe 'fields' do
    it { should have_field(:demo_status).of_type(String) }
  end

  describe 'scopes' do
    let!(:first_company) { create(:company, :demo_available) }
    let!(:second_company) { create(:company, :demo_taken) }

    describe '.demo_available' do
      it 'should find companies with demo_status: available' do
        demo_available = Company.demo_available
        demo_available.should have(1).item
        demo_available.should include(first_company)
      end
    end

    describe '.demo_taken' do
      it 'should find companies with demo_status: taken' do
        demo_available = Company.demo_taken
        demo_available.should have(1).item
        demo_available.should include(second_company)
      end
    end
  end

  describe '#demo_take' do
    context 'when demo company' do
      let!(:company) { create(:company, :demo_available) }

      it 'return a company' do
        company.demo_take.should == company
      end

      it 'take a demo company' do
        company.demo_take.demo_status.should == 'taken'
      end
    end

    context 'when not a demo company' do
      let!(:company) { create(:company) }

      it 'return nil' do
        company.demo_take.should be_nil
      end
    end
  end
end
