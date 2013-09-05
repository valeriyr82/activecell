require 'spec_helper'

describe ActiveCell::Queries::UsersToNotify, :notifications do
  let!(:first_user) { create(:user, :with_email_notifications) }
  let!(:second_user) { create(:user, :with_email_notifications) }
  let!(:third_user) { create(:user, :without_email_notifications) }

  let(:query) { described_class.new(User.all) }
  subject { query }

  describe '#for' do
    let(:query) { described_class.for(User.all, except: second_user) }

    it 'should construct a valid query object' do
      expect(query).to have(1).item
      expect(query).to include(first_user)
    end
  end

  it 'scopes only to users with enabled notifications' do
    should have(2).items

    should include(first_user)
    should include(second_user)
    should_not include(third_user)
  end

  describe '#except' do
    before { query.except(first_user) }

    it 'should exclude given user from the results' do
      should have(1).item
      should include(second_user)
    end
  end
end
