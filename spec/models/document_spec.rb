require 'spec_helper'

describe Document do
  describe 'fields' do
    it { should have_field(:response).of_type(String) }
  end

  describe 'associations' do
    it { belong_to(:company) }
  end

  describe 'validations' do
    it { should validate_presence_of(:response) }
  end
end
