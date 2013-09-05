require 'spec_helper'

describe Company::Branding, :branding do
  let!(:company) { create(:company) }
  subject { company }

  describe 'associations' do
    it { should embed_one(:branding).of_type(CompanyBranding) }
  end

  describe 'delegators' do
    it { should delegate(:color_scheme).to(:branding).with_prefix }
    it { should respond_to(:branding_color_scheme) }
  end

  describe 'callbacks' do
    describe '#after_initialize' do
      it 'should build company branding' do
        company = Company.new
        company.branding.should_not be_nil
      end
    end
  end

  shared_context 'branding overridden' do
    let!(:advisor_company) { create(:advisor_company) }
    before do
      company.invite_advisor(advisor_company)
      advisor_company.override_branding_for(company)
    end
  end

  describe '#branding_overridden?' do
    it { should respond_to(:branding_overridden?) }

    describe 'result' do
      subject { company.branding_overridden? }

      context 'when the branding is not overridden' do
        it { should be_false }
      end

      context 'when the branding is overridden by an advisor' do
        include_context 'branding overridden'

        it { should be_true }

        context 'when an access was revoked' do
          before do
            affiliation = company.advisor_company_affiliations.where(advisor_company_id: advisor_company.id).first
            affiliation.update_attribute(:has_access, false)
          end

          it { should be_false }
        end
      end
    end
  end

  describe '#branding' do
    it { should respond_to(:branding) }

    describe 'result' do
      subject { company.branding }

      context 'when the branding is not overridden' do
        it "should return company's branding" do
          should == company.branding_without_advisor
        end
      end

      context 'when the branding is overridden by an advisor' do
        include_context 'branding overridden'

        it "should return advisor's branding" do
          should == advisor_company.branding
        end
      end
    end
  end
end
