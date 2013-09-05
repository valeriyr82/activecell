require 'spec_helper'

describe Category do
  it_behaves_like 'an api document with name'
  it_behaves_like 'an api document which belongs to company'

  describe 'associations' do
    it { have_many(:children_categories) }
    it { belong_to(:parent_category) }
  end
end
