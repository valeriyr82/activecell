require 'spec_helper'

describe SignUpForm do
  let(:attributes) do
    {
      user_name: 'Test user',
      company_name: 'Test company'
    }
  end

  let(:sign_up_form) { SignUpForm.new(attributes) }
  subject { sign_up_form }

  describe '.new' do
    describe 'initialized #user' do
      subject { sign_up_form.user }

      it { should_not be_nil }
      its(:name) { should == 'Test user' }
    end

    describe 'initialized #company' do
      subject { sign_up_form.company }

      it { should_not be_nil }
      its(:name) { should == 'Test company' }
    end
  end

  describe '#valid?' do
    it 'should be valid if #user and #company are valid' do
      sign_up_form.should_not be_valid

      sign_up_form.stub(:user).and_return(build(:user))
      sign_up_form.stub(:company).and_return(build(:company))
      sign_up_form.should be_valid
    end
  end

  describe '#errors' do
    let(:attributes) { {} }

    it 'should return errors for all dependent objects' do
      subject.valid?

      errors = subject.errors
      errors.should include(:user_name)
      errors.should include(:user_email)
      errors.should include(:user_password)

      errors.should include(:company_name)
      errors.should include(:company_subdomain)
    end
  end

  describe '#save' do
    it 'returns false if is not valid' do
      subject.save.should be_false
    end

    context 'with valid params' do
      let(:attributes) do
        {
          user_name: 'Test user',
          user_email: 'test@user.com',
          user_password: 'password',
          user_password_confirmation: 'password',
          company_name: 'Test company',
          company_subdomain: 'test-domain'
        }
      end

      before { subject.save }

      it 'saves #user' do
        user = subject.user
        user.should be_persisted
        user.name.should == 'Test user'
      end

      it 'saves #company' do
        company = subject.company
        company.should be_persisted
        company.name.should == 'Test company'
      end

      it 'creates affiliations between #user and #company' do
        company = subject.company
        user_affiliations = company.user_affiliations
        user_affiliations.should have(1).item
        user_affiliations.first.user.should == subject.user
      end
    end
  end

end
