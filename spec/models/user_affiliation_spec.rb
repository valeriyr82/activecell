require 'spec_helper'

describe UserAffiliation, :advisor do

  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user) }
  end

  describe '#to_json' do
    it { should respond_to(:to_json) }

    let!(:user) { create(:user) }
    let!(:company) { create(:company, users: [user]) }
    let!(:affiliation) { company.user_affiliations.first }

    describe 'result' do
      subject { affiliation.to_json }

      it { should have_json_path('id') }
      it { should have_json_path('has_access') }
      it { should have_json_value(true).at_path('has_access') }

      it { should have_json_path('_type') }
      it { should have_json_value('UserAffiliation').at_path('_type') }

      it { should have_json_path('user/id') }
      it { should have_json_value(user.id.to_s).at_path('user/id') }

      it { should have_json_path('user/name') }
      it { should have_json_value(user.name).at_path('user/name') }

      it { should have_json_path('user/email') }
      it { should have_json_value(user.email).at_path('user/email') }
    end
  end

end
