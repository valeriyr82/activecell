require 'spec_helper'

describe User do

  describe 'fields' do
    it { should be_timestamped_document }

    it { should have_field(:intuit_openid_identifier).of_type(String) }

    it { should have_field(:name).of_type(String) }
    it { should have_field(:email).of_type(String) }
    it { should have_field(:email_notifications).of_type(Boolean).with_default_value_of(true) }

    it { should have_field(:encrypted_password).of_type(String) }
    it { should have_field(:reset_password_token).of_type(String) }
    it { should have_field(:reset_password_sent_at).of_type(Time) }
  end

  it { should be_paranoid_document }

  describe 'associations' do
    it { have_and_belong_to_many(:companies) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:password) }
  end

  describe '.find_by_email' do
    let!(:user) { create(:user, email: 'tester@gmail.com') }

    it 'returns user by email' do
      User.find_by_email('tester@gmail.com').should == user
    end

    it 'is not case sensitive' do
      User.find_by_email('Tester@Gmail.com').should == user
    end
  end

end
