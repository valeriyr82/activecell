require 'spec_helper'

describe EmployeeType do
  it_behaves_like 'an api document with name'
  it_behaves_like 'an api document which belongs to company'

  describe 'associations' do
    it { have_many(:employees) }
  end
end
