require 'spec_helper'

describe Customer do
  it_behaves_like 'an api document with name'
  it_behaves_like 'an api document which belongs to company'

  describe 'associations' do
    it { belong_to(:channel) }
    it { belong_to(:segment) }
  end
end
