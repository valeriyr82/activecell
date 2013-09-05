require 'spec_helper'

describe Company::QuickBooks, :intuit do
  let!(:company) { create(:company) }
  subject { company }

  describe 'associations' do
    it { should embed_one(:intuit_company) }
  end

  describe 'delegators' do
    it { should delegate(:token_expired?).to(:intuit_company).with_prefix(:intuit) }
    it { should delegate(:connected_at).to(:intuit_company).with_prefix(:intuit) }
    it { should delegate(:realm).to(:intuit_company).with_prefix(:intuit) }
    it { should delegate(:access_token).to(:intuit_company).with_prefix(:intuit) }
    it { should delegate(:access_secret).to(:intuit_company).with_prefix(:intuit) }
    it { should delegate(:oauth_token).to(:intuit_company).with_prefix(:intuit) }
    it { should delegate(:disconnect!).to(:intuit_company).with_prefix(:intuit) }
  end

  describe '#update_attributes_from_intuit!' do
    let(:name) { 'New name' }
    let(:attributes) { { name: name, realm: 667 } }

    before do
      create(:company, subdomain: 'this-is-taken')
      company.update_attributes_from_intuit!(attributes)
    end

    it 'should update name' do
      company.name.should == 'New name'
    end

    it 'should generate subdomain' do
      company.name.should == 'New name'
      company.subdomain.should == 'new-name'
    end

    context 'when subdomain is already taken' do
      let(:name) { 'This is taken' }

      it 'should append realm to subdomain' do
        company.name.should == 'This is taken'
        company.subdomain.should == 'this-is-taken-667'
      end
    end
  end

  describe '#intuit_token_expired?' do
    subject { company.intuit_token_expired? }

    context 'without intuit_company' do
      before { company.intuit_company = nil }
      it { should be_false }
    end
  end

  describe '#connected_to_intuit?' do
    it { should respond_to(:connected_to_intuit?) }

    describe 'result' do
      subject { company.connected_to_intuit? }

      context 'without intuit_company present' do
        before { company.intuit_company = nil }
        it { should be_false }
      end

      context 'with intuit_company present' do
        let(:intuit_company) { build(:intuit_company) }
        before { company.intuit_company = intuit_company }

        context 'when #connected_at is present' do
          before { intuit_company.connected_at = 1.day.ago }
          it { should be_true }
        end

        context 'when #connected_at is not present' do
          before { intuit_company.connected_at = nil }
          it { should be_false }
        end
      end
    end
  end

  describe '#ever_connected_to_intuit?' do
    it { should respond_to(:ever_connected_to_intuit?) }

    describe 'result' do
      subject { company.ever_connected_to_intuit? }

      context 'without intuit_company present' do
        before { company.intuit_company = nil }
        it { should be_false }
      end

      context 'with intuit_company present' do
        let(:intuit_company) { build(:intuit_company) }
        before { company.intuit_company = intuit_company }
        it { should be_true }
      end
    end
  end
end
