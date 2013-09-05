require 'spec_helper'

describe Country do
  it_behaves_like 'an api document with name'

  describe 'fields' do
    it { should have_field(:code).of_type(String) }
  end

  describe 'associations' do
    it { should have_many(:companies) }
  end
end
