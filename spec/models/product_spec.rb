require 'spec_helper'

describe Product do
  it_behaves_like 'an api document with name'
  it_behaves_like 'an api document which belongs to company'
end
